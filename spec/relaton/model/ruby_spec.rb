describe "Relaton::Model::Ruby" do
  context "parse & serialize" do
    xit "with pronunciation & text" do
      xml = <<~XML
        <ruby>
          <pronunciation value="pronunciation" script="Latn" lang="en"/>
          Text
        </ruby>
      XML
      element = Relaton::Model::Ruby.from_xml xml
      expect(element.pronunciation.value).to eq "pronunciation"
      expect(element.pronunciation.script).to eq "Latn"
      expect(element.pronunciation.lang).to eq "en"
      expect(element.to_xml).to be_equivalent_to xml
    end

    xit "with annotation & ruby" do
      xml = <<~XML
        <ruby>
          <annotation value="annotation" script="Latn" lang="en"/>
          <ruby><pronunciation value="pronunciation" script="Latn" lang="en"/>Text</ruby>
        </ruby>
      XML
      element = Relaton::Model::Ruby.from_xml xml
      expect(element.annotation.value).to eq "annotation"
      expect(element.annotation.script).to eq "Latn"
      expect(element.annotation.lang).to eq "en"
      expect(element.to_xml).to be_equivalent_to xml
    end
  end
end
