require_relative "typed_uri"

module Relaton
  module Model
    class Bsource < Shale::Mapper
      model Bib::Bsource

      include TypedUri

      @xml_mapping.instance_eval do
        root "uri"
      end
    end
  end
end
