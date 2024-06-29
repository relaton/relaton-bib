module Relaton
  module Model
    class FullName < Shale::Mapper
      include Relaton::Model::FullNameType

      model Bib::FullName

      @xml_mapping.instance_eval do
        root "name"
      end
    end
  end
end
