describe RelatonBib::Element::ToString do
  subject do
    Class.new do
      include RelatonBib::Element::ToString

      define_method :to_xml do |builder|
        builder.br
      end
    end
  end

  it "#to_s" do
    expect(subject.new.to_s).to eq "<br/>"
  end
end
