module Relaton
  module Model
    class Docidentifier < DocidentifierType
      model ::Relaton::Bib::Docidentifier

      mappings[:xml].instance_eval do
        root "docidentifier"
      end
    end
  end
end
