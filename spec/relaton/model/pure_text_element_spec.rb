describe Relaton::Model::PureTextElement do
  let(:doc) { Shale::Adapter::Nokogiri::Document.new }
  let(:parent) { Nokogiri::XML::Node.new "parent", doc.doc }

  it "text" do
    node = Nokogiri::XML::DocumentFragment.parse "<text>Text</text>"
    element = described_class.of_xml node.first_element_child
    expect(element.content).to be_instance_of Relaton::Model::PureTextElement::Content
    element.content.to_xml(parent, doc)
    expect(parent.to_xml).to be_equivalent_to "<parent>Text</parent>"
  end

  it "em" do
    node = Nokogiri::XML::DocumentFragment.parse "<em>Em</em>"
    element = described_class.of_xml node.first_element_child
    expect(element.content).to be_instance_of Relaton::Model::PureTextElement::Content
    element.content.to_xml(parent, doc)
    expect(parent.to_xml).to be_equivalent_to "<parent><em>Em</em></parent>"
  end

  it "strong" do
    node = Nokogiri::XML::DocumentFragment.parse "<strong>Strong</strong>"
    element = described_class.of_xml node.first_element_child
    expect(element.content).to be_instance_of Relaton::Model::PureTextElement::Content
    element.content.to_xml(parent, doc)
    expect(parent.to_xml).to be_equivalent_to "<parent><strong>Strong</strong></parent>"
  end
end
