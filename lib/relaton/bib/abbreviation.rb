module Relaton
  module Bib
    class Abbreviation < LocalizedString
      mappings[:xml].instance_eval do
        root "abbreviation"
      end
    end
  end
end
