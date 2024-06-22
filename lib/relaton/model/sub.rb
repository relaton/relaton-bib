module Relaton
  module Model
    class Sub < Shale::Mapper
      include PureTextElement::Mapper

      @xml_mapping.instance_eval do
        root "sub"
      end
    end
  end
end
