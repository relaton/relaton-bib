module Relaton
  module Model
    class Biblionote < Shale::Mapper
      include Relaton::Model::LocalizedMarkedUpString

      model Bib::BiblioNote

      attribute :type, Shale::Type::String

      @xml_mapping.instance_eval do
        root "note"
        map_attribute "type", to: :type
      end
    end
  end
end
