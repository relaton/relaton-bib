module Relaton
  module Model
    class Locality < Lutaml::Model::Serializable
      include BibItemLocality

      # model Relaton::Bib::Locality

      # @xml_mapping.instance_eval do
      #   root "locality"
      # end
    end
  end
end
