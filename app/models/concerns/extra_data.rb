module ExtraData
  extend ActiveSupport::Concern

  def detach_extra_data(frd=false)
    frd = true if @cached_extra_data
    if !frd
      if !skip_extra_data_processing? && extra_data_too_big? && !@already_scheduled_detach_extra_data
        @already_scheduled_detach_extra_data = true
        Worker.schedule_for(:slow, self.class, :perform_action, {'id' => self.id, 'method' => 'detach_extra_data', 'arguments' => [true]})
      end
      return true
    end
    raise "extra_data_attribute not defined" unless self.extra_data_attribute

    ApplicationRecord.using(:master) do
      if self.data['extra_data_nonce'] && !self.data[self.extra_data_attribute] && !@cached_extra_data
        if self.data['extra_data_revision'] == self.data['full_set_revision']
          private_path = self.extra_data_private_url
          private_path = private_path.sub("https://#{ENV['UPLOADS_S3_BUCKET']}.s3.amazonaws.com/", "") if private_path
          url = (Uploader.check_existing_upload(private_path) || {})[:url]
          # If we've already uploaded this exact revision, don't bother
          # re-uploading and risking a SlowDown error
          return true if url
        end
        self.assert_extra_data
      end
      # figure out a quick check to see if it's small enough to ignore
      if extra_data_too_big? || frd == 'force'
        # This will check for any clobbered events as a last resort
        self.generate_defaults if self.is_a?(LogSession)
        # generate large nonce to protect
        self.data['extra_data_nonce'] ||= GoSecure.nonce('extra_data_storage')
        # for button_sets, pull out self.data['buttons']
        # for logs, pull out self.data['events']
        extra_data = @cached_extra_data || self.data[extra_data_attribute]
        return false if extra_data == nil
        extra_data_version = 2
        private_path, public_path = self.class.extra_data_remote_paths(self.data['extra_data_nonce'], self, extra_data_version, true)
        # If upload is throttled, schedule it for later. If upload already
        # scheduled, skip upload attempt here
        if !self.is_a?(BoardDownstreamButtonSet) || (self.board && RemoteAction.where(path: self.board.global_id, action: 'upload_button_set').count == 0)
          res = upload_remote_data(extra_data, private_path, 'private')
          public_extra_data = extra_data && self.class.extra_data_public_transform(extra_data)
          if public_extra_data && res != :throttled && res != :nothing
            res = upload_remote_data(public_extra_data, public_path, 'public')
          end

          if res != :nothing && self.is_a?(BoardDownstreamButtonSet)
            self.data['extra_data_revision'] = self.data['full_set_revision']
          end
          if self.is_a?(LogSession) && (res == :nothing || res == :throttled)
            # log sessions should save to the db if upload fails, as there's
            # no way to regenerate the un-uploaded data
          else
            self.data.delete(extra_data_attribute)
          end
          # persist the nonce and the url, remove the big-data attribute
          self.data['extra_data_version'] = extra_data_version
          @skip_extra_data_update = true
          self.save
          @skip_extra_data_update = false
        end
      end
    end
    true
  end

  def upload_remote_data(data, path, type)
    # upload to "/extras/<global_id>/<nonce>/<global_id>.json"
    file = Tempfile.new("stash")
    json = self.encrypted_json(data)
    file.write(json)
    file.close
    new_checksum = Digest::MD5.hexdigest(json)
    old_path = self.data["extra_data_#{type}_path"]
    old_checksum = self.data["extra_data_#{type}_checksum"] || new_checksum || 'none'
    begin
      res = Uploader.remote_upload(path, file.path, 'text/json', new_checksum)
    rescue => e
      if e.message && e.message.match(/throttled/) && (self.is_a?(BoardDownstreamButtonSet) || self.is_a?(LogSession))
        res = {error: 'throttled'}
      else
        raise e
      end
    end

    if res && res[:error] == 'throttled' && self.is_a?(BoardDownstreamButtonSet)
      RemoteAction.where(path: self.board.global_id, action: 'upload_button_set').delete_all
      RemoteAction.create(path: self.board.global_id, act_at: 5.minutes.from_now, action: 'upload_button_set')
      return :throttled
    elsif res && res[:error] == 'throttled' && self.is_a?(LogSession)
      RemoteAction.where(path: self.global_id, action: 'upload_log_session').delete_all
      RemoteAction.create(path: self.global_id, act_at: 5.minutes.from_now, action: 'upload_log_session')
      return :throttled
    elsif res && res[:path] && (res[:path] != old_path || res[:path] != path || res[:uploaded])
      RemoteAction.where(path: res[:path], action: 'delete').delete_all
      Uploader.remote_remove_later(old_path, old_checksum) if old_path && res[:path] != old_path && res[:uploaded]
      self.data["extra_data_#{type}_path"] = res[:path]
      self.data["extra_data_#{type}_checksum"] = new_checksum
      if type == 'private'
        self.data.delete('private_cdn_url')
        self.data.delete('remote_paths') if old_checksum != new_checksum
        self.data.delete('private_cdn_revision')
      else
        self.data['extra_data_public'] = true
      end
      return res[:uploaded] ? :uploaded : :confirmed
    end
    return :nothing
  end

  def allow_encryption?
    if self.is_a?(LogSession)
      return true
    elsif self.is_a?(BoardDownstreamButtonSet) && self.board && self.board.user_id == 2
      return true
    end
    # TODO: enable for all once it has been deployed everywhere for a few months
    true
  end

  def encrypted_json(obj)
    return obj.to_json unless allow_encryption?
    if !self.data['extra_data_encryption']
      self.data['extra_data_encryption'] = ExternalNonce.init_client_encryption
      self.save
    end
    ExternalNonce.client_encrypt(obj, self.data['extra_data_encryption'])
  end

  def decrypted_json(encr)
    json = nil
    if encr && encr.match(/^aes256-/)
      if self.data['extra_data_encryption']
        json = ExternalNonce.client_decrypt(encr, self.data['extra_data_encryption'])
      end
    else
      json = JSON.parse(encr) rescue nil
    end
    json
  end
  
  def extra_data_attribute
    if self.is_a?(LogSession)
      'events'
    elsif self.is_a?(BoardDownstreamButtonSet)
      'buttons'
    else
      nil
    end
  end

  def extra_data_public_url
    return nil unless self.data && self.data['extra_data_nonce'] && self.data['extra_data_public']
    path = self.class.extra_data_remote_paths(self.data['extra_data_nonce'], self, self.data['extra_data_version'] || 0)[1]
    "#{ENV['UPLOADS_S3_CDN']}/#{path}"
  end

  def extra_data_private_url
    return nil unless self.data && self.data['extra_data_nonce']
    return nil if self.is_a?(BoardDownstreamButtonSet) && self.data['source_id']
    path = self.class.extra_data_remote_paths(self.data['extra_data_nonce'], self, self.data['extra_data_version'] || 0)[0]
    "https://#{ENV['UPLOADS_S3_BUCKET']}.s3.amazonaws.com/#{path}"
  end

  def skip_extra_data_processing?
    # don't process for any record that has the data remotely
    # but doesn't have the data locally
    if @skip_extra_data_update
      return true
    elsif @cached_extra_data
      return false
    elsif self.data && !self.data[extra_data_attribute] && self.data['extra_data_nonce']
      return true
    end
    false
  end

  def extra_data_too_big?
    return false unless ENV['REMOTE_EXTRA_DATA']
    if self.is_a?(LogSession) && self.log_type == 'session'
      user = self.user
      if self.data && self.data['events'] && self.data['events'].length > 5
        return true
      end
    elsif self.is_a?(BoardDownstreamButtonSet) && (@cached_extra_data || self.data['buttons'] || []).length > 0
      return true
    end
    # default would be to stringify and check length,
    # but can be overridden to check .data['buttons'].length, etc.
    false
  end

  def assert_extra_data
    # if big-data attribute is missing and url is defined,
    # make a remote call to retrieve the data and set it
    # to the big-data attribute (without saving)

    url = self.extra_data_private_url
    if @cached_extra_data
      self.data[self.extra_data_attribute] = @cached_extra_data
    end
    if url && !self.data[self.extra_data_attribute]
      req = Typhoeus.get(url, timeout: 3)
      data = self.decrypted_json(req.body) rescue nil
      self.data[self.extra_data_attribute] = data
    end
  end

  def clear_extra_data
    if self.data && self.data['extra_data_nonce']
      paths = self.class.extra_data_remote_paths(self.data['extra_data_nonce'], self, self.data['extra_data_version'] || 0)
      self.class.schedule(:clear_extra_data, self.global_id, paths)
    end
    true
  end

  included do
    after_save :detach_extra_data
    after_destroy :clear_extra_data
  end

  module ClassMethods
    def clear_extra_data_orphans
      # query the remote storage, search for records in batches
      # for any record that doesn't exist, remove the storage entry
      # for any record that no longer has the URL reference, remove the storage entry
    end

    def extra_data_public_transform(data)
      nil
    end
  
    def extra_data_remote_paths(nonce, obj, version=2, original_only=false)
      private_key = GoSecure.hmac(nonce, 'extra_data_private_key', 1)
      if version == 2
        dir = "extras#{nonce[0,5]}/#{self.to_s}/#{obj.global_id}/#{nonce}/"
      else
        dir = "extras#{nonce[0]}/#{self.to_s}/#{obj.global_id}/#{nonce}/"
      end
      dir = "/" + dir if version==0
      # public_path = dir + "data-#{obj.global_id}.json"
      public_path = (original_only ? nil : (obj.data || {})['extra_data_public_path']) || (dir + "data-#{obj.global_id}.json")
      private_path = (original_only ? nil : (obj.data || {})['extra_data_private_path']) || (dir + "data-#{private_key}.json")
      [private_path, public_path]
    end

    def clear_extra_data(global_id, paths)
      obj = self.find_by_global_id(global_id)
      private_path, public_path = paths #extra_data_remote_paths(nonce, obj, version)
      # Uploader.invalidate_cdn(private_path)
      if obj
        obj.data.delete('extra_data_private_path')
        obj.data.delete('extra_data_public_path')
        obj.data.delete('extra_data_public')
        obj.save
      end
      Uploader.remote_remove(private_path)
      # Uploader.invalidate_cdn(public_path)
      Uploader.remote_remove(public_path)
      # remove them both
    end
  end
end

