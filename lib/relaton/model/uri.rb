require_relative "typed_uri"

module Relaton
  module Model
    class Uri < Lutaml::Model::Serializable
      model Bib::Bsource

      include TypedUri

      mappings[:xml].instance_eval do
        root "uri"
      end
    end
  end
end
