require_relative "typed_uri"

module Relaton
  module Bib
    # Bibliographic source
    class Source < TypedUri
      mappings[:xml].instance_eval do
        root "uri"
      end
    end
  end
end
