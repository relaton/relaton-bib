describe Relaton::Model::Organization do
  context "with simple name" do
    let(:xml) do
      <<~XML
        <organization>
          <name language="en">International Organization for Standardization</name>
          <abbeviation>ISO</abbeviation>
          <uri type="src">https://www.iso.org</uri>
        </organization>
      XML
    end
  end
end
