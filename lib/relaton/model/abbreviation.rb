module Relaton
  module Module
    class Abbreviation < Shale::Mapper
      include LocalizedString

      @xml_mapping.instance_eval do
        root "abbreviation"
      end
    end
  end
end
