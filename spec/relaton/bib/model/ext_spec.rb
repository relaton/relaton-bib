describe Relaton::Bib::Ext do
  describe "#get_schema_version" do
    it "returns nil on the base class so schema-version is omitted" do
      ext = described_class.new
      expect(ext.get_schema_version).to be_nil
      expect(ext.to_xml).not_to include "schema-version"
    end

    it "is called when serializing schema_version" do
      subclass = Class.new(described_class) do
        def get_schema_version
          "9.9.9"
        end
      end
      xml = subclass.new.to_xml
      expect(xml).to include 'schema-version="9.9.9"'
    end
  end
end
