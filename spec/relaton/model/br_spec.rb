describe "Relaton::Model::Br" do
  xit "parse & serialize" do
    element = Relaton::Model::Br.from_xml("<br/>")
    expect(element.to_xml.to_s).to be_equivalent_to "<br/>"
  end
end
