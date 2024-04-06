module RelatonBib
  module LocalizedStringAttrs
    # @return [Array<String>] language Iso639 code, script Iso15924 code
    attr_reader :language, :script

    # @param [String]
    attr_reader :locale

    #
    # Initialize localization attributes
    # multiple languages and scripts possible: comma delimit them if so
    #
    # @param [Array<String>, String] language language code Iso639
    # @param [Array<String>, String] script script code Iso15924
    # @param [String, nil] locale
    #
    def initialize(**args)
      @language = arg_to_array args[:language]
      @script = arg_to_array args[:script]
      @locale = args[:locale]
    end

    def arg_to_array(arg)
      arg.is_a?(Array) ? arg : arg.to_s.split(",")
    end

    def to_xml(builder) # rubocop:disable Metrics/AbcSize
      builder.parent[:language] = language.join(",") if language.any?
      builder.parent[:script] = script.join(",") if script.any?
      builder.parent[:locale] = locale if locale
    end

    def to_hash
      hash = {}
      hash["language"] = language if language.any?
      hash["script"] = script if script.any?
      hash["locale"] = locale if locale
      hash
    end

    def to_asciibib(prefix = "")
      out = ""
      out += "#{prefix}.language:: #{language.join(",")}\n" if language.any?
      out += "#{prefix}.script:: #{script.join(",")}\n" if script.any?
      out += "#{prefix}.locale:: #{locale}\n" if locale
      out
    end
  end
end
