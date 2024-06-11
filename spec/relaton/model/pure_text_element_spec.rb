describe Relaton::Model::PureTextElement do
  let(:dummy_class) do
    Class.new(Shale::Mapper) do
      include Relaton::Model::PureTextElement
      attribute :content, Relaton::Model::PureTextElement::Content

      xml do
        map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      end

      def content_from_xml(model, node)
        model.content = Relaton::Model::PureTextElement::Content.of_xml node.instance_variable_get(:@node)
      end

      def content_to_xml(model, parent, doc)
        model.content.to_xml parent, doc
      end
    end
  end

  let(:xml) do
    <<~XML
      <content>
        Text
        <em>Em</em>
      </content>
    XML
  end

  it "from XML" do
    dummy = dummy_class.from_xml xml
    expect(dummy.content).to be_instance_of Relaton::Model::PureTextElement::Content
    expect(dummy.to_xml).to be_equivalent_to xml
  end
end
