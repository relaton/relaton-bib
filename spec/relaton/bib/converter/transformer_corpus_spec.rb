require "spec_helper"

# Regression corpus for the strict RFC XML v3 export mode, harvested
# from the metanorma-ietf model-driven transformer's spec suite and
# fixtures (metanorma/metanorma-ietf#233), plus synthetic monograph
# and journal-article items the suite lacked. Provenance and refresh
# notes: spec/fixtures/transformer_corpus/README.adoc.
#
# Assertions are structural sentinels distilled from the differential
# review of PR #125, deliberately NOT golden files: they pin the
# fixed defect classes without freezing open rendering choices.
describe Relaton::Bib::Converter::BibXml, "transformer corpus (v3 mode)" do
  CORPUS = Dir[File.join(__dir__, "../../../fixtures/transformer_corpus/*.xml")]
    .sort.freeze

  # roles that must never surface as standalone organization-authors
  NON_AUTHOR_ORGS = ["RFC Publisher", "RFC Series"].freeze

  CORPUS.each do |path|
    context File.basename(path) do
      let(:item) { Relaton::Bib::Item.from_xml(File.read(path, encoding: "UTF-8")) }
      let(:anchor) do
        id = item.respond_to?(:id) && item.id
        id && !id.to_s.empty? ? id.to_s : nil
      end
      subject(:xml) do
        described_class.from_item(item, v3: true, anchor: anchor).to_xml
      end

      it "exports without raising and parses as XML" do
        doc = Nokogiri::XML(xml) { |c| c.strict }
        expect(doc.root.name).to eq("reference").or eq("referencegroup")
      end

      it "meets the v3 structural sentinels" do
        doc = Nokogiri::XML(xml)

        # v3 mode never emits the deprecated format element
        expect(doc.xpath("//format")).to be_empty

        # publisher/authorizer contributors are not authors
        doc.xpath("//author/organization").each do |org|
          expect(NON_AUTHOR_ORGS).not_to include(org.text.strip)
        end

        # every front carries a title and at least one author
        doc.xpath("//front").each do |front|
          expect(front.at("./title")).not_to be_nil
          expect(front.xpath("./author")).not_to be_empty
        end

        # no title carries element children (v3 title is text-only)
        doc.xpath("//title").each do |title|
          expect(title.element_children).to be_empty
        end

        # no duplicate seriesInfo on one reference
        doc.xpath("//reference").each do |ref|
          pairs = ref.xpath(".//seriesInfo").map { |s| [s["name"], s["value"]] }
          expect(pairs.uniq.size).to eq(pairs.size)
        end

        # ascii* attributes, when present, carry letters — never
        # degenerate "." / " " remainders of non-Latin folding
        doc.xpath("//@*[starts-with(name(), 'ascii')]").each do |attr|
          expect(attr.value).to match(/[A-Za-z]/)
        end

        # abstracts carry text, not escaped or embedded source <p>
        doc.xpath("//abstract//t").each do |t|
          expect(t.text).not_to include("&lt;p")
          expect(t.at("./p")).to be_nil
        end
      end
    end
  end
end
