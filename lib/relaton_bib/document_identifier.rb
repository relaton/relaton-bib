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
      @id = Element::TextElement.parse(@id) if @id.is_a?(String)
    end

    #
    # Identifier as string.
    #
    # @return [String]
    #
    def id(_ = nil)
      @id.map(&:to_s).join
    end

    #
    # Set identifier.
    #
    # @param [String] id
    #
    # @return [void]
    #
    def id=(id)
      @id = Element::TextElement.parse(id)
    end

    # in docid manipulations, assume ISO as the default: id-part:year
    def remove_part
      case @type
      when "Chinese Standard" then @id = Element::TextElement.parse(id.sub(/\.\d+/, ""))
      else @id = Element::TextElement.parse(id.sub(/-[^:]+/, ""))
      end
    end

    def remove_date
      case @type
      when "Chinese Standard" then @id = Element::TextElement.parse(id.sub(/-[12]\d\d\d/, ""))
      else @id = Element::TextElement.parse(id.sub(/:[12]\d\d\d/, ""))
      end
    end

    def all_parts
      @id = Element::TextElement.parse("#{id} (all parts)")
    end
  end
end
