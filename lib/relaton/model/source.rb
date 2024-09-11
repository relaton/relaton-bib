require_relative "typed_uri"

module Relaton
  module Model
    class Source < Lutaml::Model::Serializable
      model Bib::Source

      include TypedUri

      mappings[:xml].instance_eval do
        root "uri"
      end
    end
  end
end
