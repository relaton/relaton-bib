module Relaton
  module Model
    class Classification < DocidentifierType
      model Bib::Classification

      mappings[:xml].instance_eval do
        root "docidentifier"
      end
    end
  end
end
