describe Relaton::Model::TextElement do
  let(:doc) { Shale::Adapter::Nokogiri::Document.new }
  let(:parent) { Nokogiri::XML::Node.new "parent", doc.doc }

  shared_examples "parse & serialize" do |content|
    it do
      node = Nokogiri::XML::DocumentFragment.parse content
      element = described_class.of_xml node.children.first
      expect(element).to be_instance_of Relaton::Model::TextElement
      element.add_to_xml(parent, doc)
      expect(parent.to_xml).to be_equivalent_to "<parent>#{content}</parent>"
    end
  end

  it_behaves_like "parse & serialize", "Text"
  it_behaves_like "parse & serialize", "<em>Em</em>"
  it_behaves_like "parse & serialize", "<eref>ERef</eref>"
  it_behaves_like "parse & serialize", "<strong>Strong</strong>"
  it_behaves_like "parse & serialize", "<stem type='MathML'>Text</stem>"
  it_behaves_like "parse & serialize", "<sub>Sub</sub>"
  it_behaves_like "parse & serialize", "<sup>Sup</sup>"
  it_behaves_like "parse & serialize", "<tt>Tt</tt>"
  it_behaves_like "parse & serialize", "<underline style='dotted'>Text</underline>"
  it_behaves_like "parse & serialize", "<keyword>Text</keyword>"
  it_behaves_like "parse & serialize", "<strike>Text</strike>"
  it_behaves_like "parse & serialize", "<smallcap>Text</smallcap>"
  it_behaves_like "parse & serialize", "<br/>"
end
