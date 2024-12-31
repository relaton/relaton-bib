module Relaton
  module Model
    class Abstract < LocalizedString
      model Bib::LocalizedString

      xml do
        root "abstract"
      end
    end
  end
end
