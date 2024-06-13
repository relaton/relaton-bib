describe Relaton::Model::PureTextElement do
  let(:doc) { Shale::Adapter::Nokogiri::Document.new }
  let(:parent) { Nokogiri::XML::Node.new "parent", doc.doc }

  shared_examples "parse & serialize" do |content|
    it do
      node = Nokogiri::XML::DocumentFragment.parse content
      element = described_class.of_xml node.children.first
      expect(element).to be_instance_of Relaton::Model::PureTextElement
      element.add_to_xml(parent, doc)
      expect(parent.to_xml).to be_equivalent_to "<parent>#{content}</parent>"
    end
  end

  it_behaves_like "parse & serialize", "Text"
  it_behaves_like "parse & serialize", "<em>Em</em>"
  it_behaves_like "parse & serialize", "<strong>Strong</strong>"
  it_behaves_like "parse & serialize", "<sub>Sub</sub>"
  it_behaves_like "parse & serialize", "<sup>Sup</sup>"
  it_behaves_like "parse & serialize", "<tt>Tt</tt>"
  it_behaves_like "parse & serialize", "<underline style='dotted'>Text</underline>"
  it_behaves_like "parse & serialize", "<strike>Text</strike>"
end
