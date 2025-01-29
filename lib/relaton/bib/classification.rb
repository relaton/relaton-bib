module Relaton
  module Bib
    class Classification < DocidentifierType
      mappings[:xml].instance_eval do
        root "docidentifier"
      end
    end
  end
end
