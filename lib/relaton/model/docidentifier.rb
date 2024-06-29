module Relaton
  module Model
    class DocIdentifier < Shale::Mapper
      include LocalizedMarkedUpString

      model Bib::Docidentifier

      attribute :type, Shale::Type::String
      attribute :scope, Shale::Type::String
      attribute :primary, Shale::Type::Boolean

      @xml_mapping.instance_eval do
        root "docidentifier"
        map_attribute "type", to: :type
        map_attribute "scope", to: :scope
        map_attribute "primary", to: :primary
      end
    end
  end
end
