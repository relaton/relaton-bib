module RelatonBib
  #
  # Document identifier.
  #
  # @id [String, Array<RelatonBib::Element::Text, RelatonBib::Element::Base>]
  #
  class DocumentIdentifier
    include RelatonBib::DocumentIdentifierBase

    # @param id [String, Array<RelatonBib::Element::Text, RelatonBib::Element::Base>]
    # @param type [String, nil]
    # @param scope [String, nil]
    # @param primary [Bolean, nil]
    # @param language [String, nil]
    def initialize(**args)
      super
      @id = Element.parse_text_elements(@id) if @id.is_a?(String)
    end
    #
    # Identifier as string.
    #
    # @return [String]
    #
    def id(_ = nil)
      @id.map(&:to_s).join
    end

    # in docid manipulations, assume ISO as the default: id-part:year
    def remove_part
      case @type
      when "Chinese Standard" then @id = Element.parse_text_elements(id.sub(/\.\d+/, ""))
      else @id = Element.parse_text_elements(id.sub(/-[^:]+/, ""))
      end
    end

    def remove_date
      case @type
      when "Chinese Standard" then @id = Element.parse_text_elements(id.sub(/-[12]\d\d\d/, ""))
      else @id = Element.parse_text_elements(id.sub(/:[12]\d\d\d/, ""))
      end
    end

    def all_parts
      @id = Element.parse_text_elements("#{id} (all parts)")
    end
  end
end
