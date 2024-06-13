module RelatonBib
  module Factory
    def create_docid(**args)
      case args[:type]
      when "URN" then DocumentIdentifierUrn.new(**args)
      else DocumentIdentifier.new(**args)
      end
    end
  end
end
