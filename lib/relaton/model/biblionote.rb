module Relaton
  module Model
    class Biblionote < Lutaml::Model::Serializable
      include Relaton::Model::LocalizedString

      model Bib::BiblioNote

      attribute :type, Lutaml::Model::Type::String

      mappings[:xml].instance_eval do
        root "note"
        map_attribute "type", to: :type
      end
    end
  end
end
