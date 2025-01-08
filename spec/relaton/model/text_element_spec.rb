describe Relaton::Model::TextElement do
  # let(:doc) { Shale::Adapter::Nokogiri::Document.new }
  # let(:parent) { Nokogiri::XML::Node.new "parent", doc.doc }

  let(:dummy_class) do
    Class.new(Lutaml::Model::Serializable) do
      include Relaton::Model::TextElement
      attribute :content, :string
      xml do
        root "parent"
        map_all to: :content
      end
    end
  end

  shared_examples "parse & serialize" do |content|
    it do
      # node = Nokogiri::XML::DocumentFragment.parse content
      # element = described_class.of_xml node.children.first
      # expect(element).to be_instance_of Relaton::Model::TextElement
      # element.add_to_xml(parent)
      xml = "<parent>#{content}</parent>"
      node = dummy_class.from_xml xml
      expect(node.to_xml).to be_equivalent_to xml
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
  it_behaves_like "parse & serialize", "<ruby><pronunciation value='Val'/>Text</ruby>"
  it_behaves_like "parse & serialize", "<strike>Text</strike>"
  it_behaves_like "parse & serialize", "<smallcap>Text</smallcap>"
  it_behaves_like "parse & serialize", "<xref target='IDREF' type='inline'>Text</xref>"
  it_behaves_like "parse & serialize", "<br/>"
  it_behaves_like "parse & serialize", "<link target='URL' type='inline'>Text</link>"
  it_behaves_like "parse & serialize", "<hr/>"
  it_behaves_like "parse & serialize", "<pagebreak/>"
  it_behaves_like "parse & serialize", "<bookmark id='ID'/>"
  it_behaves_like "parse & serialize", "<image id='ID' src='SRC' mimetype='MIME'/>"
  it_behaves_like "parse & serialize", "<index><primary>Primary</primary></index>"
  it_behaves_like "parse & serialize", <<~XML
    <index-xref also="true"><primary>Primary</primary><target>Text</target></index-xref>
  XML
end
