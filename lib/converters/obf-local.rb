module Converters::ObfLocal
  require 'typhoeus'
  WORDS = {
    "germs": {path: "bacteria.svg", url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/Bacteria_480_g.svg", license: {type: "CC-By", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/us/", source_url: "Maxim Kulikov", author_name: "Blair Adams", author_url: "http://thenounproject.com/maxim221"}},
    "virus": {path: "virus.png", url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/virus.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "http://catedu.es/arasaac/", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}},
    "coronavirus": {path: "bacteria2.svg", url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/Bacteria_851_g.svg", license: {type: "CC-By", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/us/", source_url: "http://thenounproject.com/", author_name: "Blair Adams", author_url: "http://thenounproject.com/blairwolf"}},
    "sick": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to%20get%20sick.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "http://catedu.es/arasaac/", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "sick.png"},
    "pandemic": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/Earth.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "https://mulberrysymbols.org/", author_name: "Paxtoncrafts Charitable Trust", author_url: "http://straight-street.org/lic.php"}, path: "pandemic.svg"},
    "quarantine": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/barrier_285_136215.svg", license: {type: "CC By", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/us/", source_url: "http://thenounproject.com/", author_name: "Tyler Glaude", author_url: "http://thenounproject.com/tyler.glaude"}, path: "quarantine.svg"},
    "safe": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/security.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "http://catedu.es/arasaac/", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "safe.png"},
    "social-distancing": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/take%20away_2.pnghttps://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/take%20away_2.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "http://catedu.es/arasaac/", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "social-distancing.png"},
    "dont-touch": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/don't touch!.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "dont-touch.png"},
    "soap": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/soap.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "soap.png"},
    "sanitizer": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/liquid soap.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "sanitizer.svg"},
    "dirty": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/dirty.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "dirty.png"},
    "clean-hands": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/clean hands.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "clean-hands.svg"},
    "20-seconds": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/timer_398_g.svg", license: {type: "CC By", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/us/", source_url: "", author_name: "Dmitry Mamaev", author_url: "http://thenounproject.com/shushpo"}, path: "20-seconds.svg"},
    "wash-hands": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to wash one's hands.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "wash-hands.png"},
    "dry-hands": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/dry hands , to.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "dry-hands.svg"},
    "blanket": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/blanket_1.png", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "blanket.png"},
    "hot": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/hot.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "hot.png"},
    "cold": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/cold_3.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "cold.png"},
    "lay": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to lay down in the bed_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "lay.png"},
    "yawn": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/yawn_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "yawn.png"},
    "snak": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/mid-morning snack_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "snak.png"},
    "drink": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to have.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "drink.png"},
    "thirsty": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/thirsty_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "thirsty.png"},
    "hungry": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/hungry.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "hungry.png"},
    "face-mask": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/twemoji/1f637.svg", license: {type: "CC BY", copyright_notice_url: "https://creativecommons.org/licenses/by/4.0/", source_url: "https://raw.githubusercontent.com/twitter/twemoji/gh-pages/svg/1f637.svg", author_name: "Twitter. Inc.", author_url: "https://www.twitter.com"}, path: "face-mask.svg"},
    "theater": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/Theater-2fc9e1c8d3.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/", source_url: "http://thenounproject.com/site_media/svg/76610707-1ef3-4650-ba07-57cadb8d56c5.svg", author_name: "Chiara Cozzolino", author_url: "http://thenounproject.com/chlapa"}, path: "theater.svg"},
    "mall": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/tawasol/Mall.png", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/4.0/", source_url: "", author_name: "Mada, HMC and University of Southampton", author_url: "http://www.tawasolsymbols.org/"}, path: "mall.png"},
    "park": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/tawasol/Park.png", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/4.0/", source_url: "", author_name: "Mada, HMC and University of Southampton", author_url: "http://www.tawasolsymbols.org/"}, path: "park.png"},
    "apart": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to grow apart_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "apart.png"},
    "shake-hands": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/shake hands.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "shake-hands.png"},
    "smell": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/sense of smell.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "smell.png"},
    "quiet": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/Quiet-Space_281_g.svg", license: {type: "public domain", copyright_notice_url: "https://creativecommons.org/publicdomain/zero/1.0/", source_url: "", author_name: "Iconathon", author_url: "http://thenounproject.com/Iconathon1"}, path: "quiet.svg"},
    "not": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/former.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "not.png"},
    "leave": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/tawasol/leave.jpg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/4.0/", source_url: "", author_name: "Mada, HMC and University of Southampton", author_url: "http://www.tawasolsymbols.org/"}, path: "leave.jpg"},
    "noisy": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/noisy.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "noisy.png"},
    "when": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/Time-880d4b0e2b.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/", source_url: "http://thenounproject.com/site_media/svg/13234e94-6b08-4d4d-abb8-03c7af444b62.svg", author_name: "Wayne Middleton", author_url: "http://thenounproject.com/Wayne25uk"}, path: "when.svg"},
    "medication": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/medicine.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "medication.png"},
    "flashlight": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/twemoji/1f526.svg", license: {type: "CC BY", copyright_notice_url: "https://creativecommons.org/licenses/by/4.0/", source_url: "https://raw.githubusercontent.com/twitter/twemoji/gh-pages/svg/1f526.svg", author_name: "Twitter. Inc.", author_url: "https://www.twitter.com"}, path: "flashlight.svg"},
    "water": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/drink.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "water.png"},
    "food": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/food.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "food.svg"},
    "money": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/Money-20ed6d2342.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/", source_url: "http://thenounproject.com/term/money/", author_name: "Atelier Iceberg", author_url: "http://thenounproject.com/Atelier Iceberg"}, path: "money.svg"},
    "help": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/I need help.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "help.png"},
    "sand-box": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/sandbox.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "sand-box.png"},
    "headphones": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/Headphones-c99fe70250.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/", source_url: "http://thenounproject.com/site_media/svg/c0707be8-cb67-4715-93d1-619cc7d82e35.svg", author_name: "Kevin Wynn", author_url: "http://thenounproject.com/imamkevin"}, path: "headphones.svg"},
    "cover-ears": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/ear ache_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "cover-ears.png"},
    "calm": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/nice_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "calm.png"},
    "ask": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/ask_2.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "ask.png"},
    "why": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/why.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "why.svg"},
    "happening": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/what are you studying.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "happening.png"},
    "dont-know": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/I do not know.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "dont-know.png"},
    "home": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/twemoji/1f3e0.svg", license: {type: "CC BY", copyright_notice_url: "https://creativecommons.org/licenses/by/4.0/", source_url: "https://raw.githubusercontent.com/twitter/twemoji/gh-pages/svg/1f3e0.svg", author_name: "Twitter. Inc.", author_url: "https://www.twitter.com"}, path: "home.svg"},
    "school": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/high school - secondary school.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "school.png"},
    "friends": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/friends_3.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "friends.png"},
    "ask2": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/so do i.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "ask2.png"},
    "take-off": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/take off cap , to.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "take-off.svg"},
    "want": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to want.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "want.png"},
    "off": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/turn off the light_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "off.png"},
    "on": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/turn on the light.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "on.png"},
    "breathe": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to breathe_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "breathe.png"},
    "mask": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/mask_2.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "mask.png"},
    "excited": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/twemoji/1f604.svg", license: {type: "CC BY", copyright_notice_url: "https://creativecommons.org/licenses/by/4.0/", source_url: "https://raw.githubusercontent.com/twitter/twemoji/gh-pages/svg/1f604.svg", author_name: "Twitter. Inc.", author_url: "https://www.twitter.com"}, path: "excited.svg"},
    "happy": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/happy_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "happy.png"},
    "scared": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/scared_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "scared.png"},
    "bored": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to get tired.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "bored.png"},
    "sad": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/sad.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "sad.png"},
    "frustrated": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to get angry with_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "frustrated.png"},
    "mad": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to get angry with_4.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "mad.png"},
    "ok": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/ok.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "ok.png"},
    "brave": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/adventure.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "brave.png"},
    "look": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/What are yopu looking at.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "look.png"},
    "next-time": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/next month.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "next-time.svg"},
    "ipad": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/iPad-c88c4045fa.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/", source_url: "http://thenounproject.com/site_media/svg/6cecc96d-a585-4100-b65c-dd73322c1aed.svg", author_name: "Michael Loupos", author_url: "http://thenounproject.com/mikeydoesit"}, path: "ipad.svg"},
    "tv": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/watch TV_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "tv.png"},
    "house": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/icomoon/house.svg", license: {type: "CC By-SA 3.0", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/3.0/us/", source_url: "http://www.entypo.com/", author_name: "Daniel Bruce", author_url: "http://danielbruce.se/"}, path: "house.svg"},
    "bed": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/bed.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "bed.png"},
    "pet": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/pet.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "pet.png"},
    "family": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/family_5.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "family.png"},
    "blanket2": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/blanket.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "blanket2.svg"},
    "stay-at-home": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/home.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "stay-at-home.png"},
    "that-was-scary": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/noun-project/Scared_176_320418.svg", license: {type: "CC By", copyright_notice_url: "http://creativecommons.org/licenses/by/3.0/us/", source_url: "", author_name: "Oliviu Stoian", author_url: "http://thenounproject.com/smashicons"}, path: "that-was-scary.svg"},
    "go-home": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/home.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "go-home.png"},
    "miss-friends": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/friends.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "miss-friends.png"},
    "stop": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/sclera/stop.png", license: {type: "CC BY-NC", copyright_notice_url: "http://creativecommons.org/licenses/by-nc/2.0/", source_url: "", author_name: "Sclera", author_url: "http://www.sclera.be/en/picto/copyright"}, path: "stop.png"},
    "who": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/who.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "who.png"},
    "what": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/what.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "what.png"},
    "where": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/where.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "where.svg"},
    "can": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/can you see it_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "can.png"},
    "in": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/in.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "in.svg"},
    "up": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/mulberry/up.svg", license: {type: "CC BY-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-sa/2.0/uk", source_url: "", author_name: "Paxtoncrafts Charitable Trust ", author_url: "http://straight-street.org/lic.php"}, path: "up.svg"},
    "she": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/she.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "she.png"},
    "you": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/you.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "you.png"},
    "put": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/put in a safe place_2.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "put.png"},
    "open": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/open.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "open.png"},
    "different": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/different.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "different.png"},
    "good": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/good.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "good.png"},
    "get": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to receive.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "get.png"},
    "finished": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/finish.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "finished.png"},
    "here": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/here_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "here.png"},
    "it": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/that_2.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "it.png"},
    "some": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/some_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "some.png"},
    "all": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/all - everything.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "all.png"},
    "that": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/that_2.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "that.png"},
    "same": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/the same_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "same.png"},
    "do": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to do exercise_2.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "do.png"},
    "he": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/he.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "he.png"},
    "I": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/I.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "I.png"},
    "turn": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/turn.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "turn.png"},
    "go": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to go_3.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "go.png"},
    "more": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/more_1.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "more.png"},
    "make": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/make - do - write.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "make.png"},
    "like": {url: "https://d18vdu4p71yql0.cloudfront.net/libraries/arasaac/to like.png", license: {type: "CC BY-NC-SA", copyright_notice_url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", source_url: "", author_name: "Sergio Palao", author_url: "http://www.catedu.es/arasaac/condiciones_uso.php"}, path: "like.png"},
  }

  def self.generate_local(locale, path)
    if path.match(/^http/)
      path = path.split(/\//)[-2, 2].join('/')
    end
    words ||= {}
    brd = Board.find_by_path(path)
    imgs = []
    lines = []
    grid = BoardContent.load_content(brd, 'grid')
    buttons = brd.buttons.map{|b| {}.merge(b) }
    name = brd.settings['name']
    if brd.settings['locale'] != locale
      trans = BoardContent.load_content(brd, 'translations') || {}
      name = (trans['board_name'] || {})[locale] || name
      buttons.each do  |btn|
        bt = (trans[btn['id'].to_s] || {})
        btn_trans = bt[locale] || {}
        if btn_trans['label']
          btn['other_word'] = btn['label']
          btn['label'] = btn_trans['label']
          btn['eng_label'] = (bt['en'] || btn['en_US'] || {})['label']
          btn['vocalization'] = btn_trans['vocalization']
          btn['inflections'] = btn_trans['inflections']
        end
      end
    end
    src = Board.find_by_path("emergency/" + path.split(/\//)[1].gsub(/_\d+/, '').gsub(/_/, '-'))
    lines << "{id: '#{path.split(/\//)[1].gsub(/_/, '-')}-#{locale}', name: '#{name}', rows: #{grid['rows'].to_i}, cols: #{grid['columns'].to_i}, key: '#{path}', starter: true, buttons: [";
    images = brd.known_button_images
    word_list = Converters::ObfLocal::WORDS.to_a
    grid['order'].each_with_index do |row, idx|
      row_content = []
      row.each_with_index do |id, jdx|
        btn = buttons.detect{|b| b['id'].to_s == id.to_s }
        if btn
          bi = images.detect{|i| i.global_id == btn['image_id'] }
          word = bi && word_list.detect{|w| w[1][:url] == URI.escape(bi.url) || w[1][:url]  == bi.url }
          word ||= word_list.detect{|w| btn['eng_label'] && w[0] == btn['eng_label'] }
          if !word && src
            grid2 = BoardContent.load_content(src, 'grid')['order'] || []
            id2 = (grid2[idx] || [])[jdx]
            btn2 = src.buttons.detect{|b| b['id'].to_s == id.to_s }
            if btn2
              bi2 = src.known_button_images.detect{|i| i.global_id == btn2['image_id']}
              word = bi2 && word_list.detect{|w| w[1][:url] == URI.escape(bi2.url) || w[1][:url]  == bi2.url }
            end
          end
          if word && (word[0].to_s != btn['label'].to_s)
            row_content << "{label: \"#{btn['label']}\", word: \"#{word[0]}\"}"
          else
            row_content << "{label: \"#{btn['label']}\"}"
          end
        else
          row_content << 'null'
        end
      end
      lines << "  [#{row_content.join(', ')}],";
    end.length
    lines << "], license: {type: '#{brd.settings['license']['type']}', copyright_notice_url: '#{brd.settings['license']['copyright_notice_url']}', author_name: '#{brd.settings['license']['author_name']}', author_url: '#{brd.settings['license']['author_url']}'}},"
    lines << ""
    brd.known_button_images.each do |bi|
      btn = brd.buttons.detect{|b| b['image_id'] == bi.global_id }
      if btn && bi
        lines << "\"#{btn['label']}\": {url: \"#{bi.url}\", license: {type: '#{bi.settings['license']['type']}', copyright_notice_url: '#{bi.settings['license']['copyright_notice_url']}', source_url: '#{bi.settings['license']['source_url']}', author_name: '#{bi.settings['license']['author_name']}', author_url: '#{bi.settings['license']['author_url']}'}},"
      end
    end
    puts ""; lines.each{|l| puts l}; puts ""
  end

  def self.ingest_locale(list, locale, overwrite=false)
    list.each do |brd|
      copy = brd[:key] && Board.find_by_path(brd[:key])
      next unless copy
      source = Board.find_by_path("emergency/#{brd[:key].split(/\//)[1].gsub(/_\d+/, '').gsub(/-#{locale}$/, '')}")
      if !source || source != copy.parent_board
        puts "MISSING SOURCE FOR #{brd[:key]}"
        next
      end
      source.import_translation(copy, locale, overwrite)
      puts "{id: '#{brd[:id]}', name: '#{brd[:name]}', rows: #{brd[:rows]}, cols: #{brd[:cols]}, key: '#{source.key}', starter: #{brd[:starter]}, buttons: ["
      brd[:buttons].each do |row|
        btns = []
        row.each do |btn|
          btns << btn.to_json
        end
        puts "  [#{btns.join(', ')}],"
      end
      puts "], license: #{brd[:license].to_json}},"
    end
    puts "\n"
  end

  def self.save_local
    lines = []
    WORDS.each do |word, data|
      if !data[:path] && data[:url]
        ext = data[:url].split(/\./)[-1]
        res = Typhoeus.get(URI.escape(data[:url]))
        if res.success?
          f = File.open("./public/images/emergency/#{word}.#{ext}", 'wb')
          f.write(res.body)
          f.close
          data[:path] = "#{word}.#{ext}"
        end
      end
      lines << "  \"#{word}\": #{data.to_s.gsub(/\:(\w+)=>/, '\1: ')},"
    end.length
    puts ""; puts ""; lines.each{|l| puts l }; puts ""; puts ""
  end
end