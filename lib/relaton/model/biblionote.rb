module Relaton
  module Model
    class Biblionote < Lutaml::Model::Serializable
      include Relaton::Model::LocalizedMarkedUpString

      model Bib::BiblioNote

      attribute :type, Lutaml::Model::Type::String

      @xml_mapping.instance_eval do
        root "note"
        map_attribute "type", to: :type
      end
    end
  end
end
