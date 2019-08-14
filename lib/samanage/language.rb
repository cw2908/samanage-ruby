# frozen_string_literal: true

module Samanage
  LANGUAGE = {
    "arabic" => "ar",
    "belarusian" => "be",
    "bulgarian" => "bg",
    "catalan" => "ca",
    "chinese simplified" => "zh-cn",
    "chinese traditional" => "zh-tw",
    "croatian" => "hr",
    "czech" => "cs",
    "danish" => "da",
    "dutch" => "nl",
    "english" => "en",
    "estonian" => "et",
    "finnish" => "fi",
    "french" => "fr",
    "german" => "de",
    "greek" => "el",
    "hebrew" => "he",
    "hindi" => "hi-in",
    "hungarian" => "hu",
    "bahasa indonesia (indonesian)" => "id",
    "italian" => "it",
    "japanese" => "ja",
    "korean" => "ko",
    "latvian" => "lv",
    "lithuanian" => "lt",
    "malay" => "ms",
    "macedonian" => "mk",
    "norwegian" => "nb",
    "persian" => "fa",
    "polish" => "pl",
    "portuguese (brazil)" => "pt-br",
    "portuguese (portugal)" => "pt-pt",
    "romanian" => "ro",
    "russian" => "ru",
    "serbian" => "sr",
    "slovak" => "sk",
    "slovenian" => "sl",
    "spanish" => "es",
    "spanish  (latin america)" => "es-419",
    "swedish" => "sv",
    "thai" => "th",
    "turkish" => "tr",
    "ukrainian" => "uk",
    "vietnamese" => "vi",
  }
  def self.lookup_language(language)
    LANGUAGE[language.to_s.downcase] ||= (language.to_s.downcase if LANGUAGE.values.include?(language.to_s.downcase))
  end
end
