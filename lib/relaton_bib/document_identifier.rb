module RelatonBib
  # Document identifier.
  class DocumentIdentifier
    # @return [String]
    attr_reader :id

    # @return [String, NilClass]
    attr_reader :type

    # @param id [String]
    # @param type [String, NilClass]
    def initialize(id:, type: nil)
      @id   = id
      @type = type
    end

    # in docid manipulations, assume ISO as the default: id-part:year
    def remove_part
      case @type
      when "Chinese Standard" then @id.sub!(/\.\d+/, "")
      else
        @id.sub!(/-\d+/, "")
      end
    end

    def remove_date
      case @type
      when "Chinese Standard" then @id.sub!(/-[12]\d\d\d/, "")
      else
        @id.sub!(/:[12]\d\d\d/, "")
      end
    end

    def all_parts
      @id += " (all parts)"
    end

    #
    # Add docidentifier xml element
    #
    # @param [Nokogiri::XML::Builder] builder
    #
    def to_xml(builder)
      builder.docidentifier(id, type: type)
    end
  end
end
