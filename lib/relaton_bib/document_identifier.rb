module RelatonBib
  # Document identifier.
  class DocumentIdentifier
    # @return [String]
    attr_reader :id

    # @return [String, NilClass]
    attr_reader :type, :scope

    # @param id [String]
    # @param type [String, NilClass]
    # @param scoope [String, NilClass]
    def initialize(id:, type: nil, scope: nil)
      @id    = id
      @type  = type
      @scope = scope
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
      element = builder.docidentifier id
      element[:type] = type if type
      element[:scope] = scope if scope
    end

    # @return [Hash]
    def to_hash
      hash = { "id" => id }
      hash["type"] = type if type
      hash["scope"] = scope if scope
      hash
    end
  end
end
