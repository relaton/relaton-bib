describe RelatonBib::Element::ToString do
  subject do
    Class.new do
      include RelatonBib::Element::ToString

      define_method :to_xml do |builder|
        builder.br
      end
    end
  end

  it "to_string" do
    expect(subject.new.to_string).to eq "<br/>"
  end
end
