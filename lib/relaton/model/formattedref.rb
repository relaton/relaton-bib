module Relaton
  module Model
    class Formattedref < Shale::Mapper
      include TextElement::Mapper

      model Bib::Formattedref

      @xml_mapping.instance_eval do
        root "formattedref"
      end
    end
  end
end
