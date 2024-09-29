require_relative "typed_uri"

module Relaton
  module Model
    class Source < TypedUri
      model Bib::Source

      mappings[:xml].instance_eval do
        root "uri"
      end
    end
  end
end
