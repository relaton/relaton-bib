module Relaton
  module Model
    class Em < Shale::Mapper
      class Content < Shale::Mapper
        include Model::PureTextElement

        # attribute :stem, Stem
        # attribute :eref, Eref
        # attribute :xref, Xref
        # attribute :hyperlink, Hyperlink
        # attribute :index, Index
        # attribute :index_xref, IndexXref

        # @xml_mapping.instance_eval do
        #   map_element "stem", to: :stem
        #   map_element "eref", to: :eref
        #   map_element "xref", to: :xref
        # end
      end

      attribute :content, Content, collection: true

      @xml_mapping.instance_eval do
        self
      end
    end
  end
end
