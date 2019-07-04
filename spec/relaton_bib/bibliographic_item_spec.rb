# frozen_string_literal: true

    item_hash = {
        "id" => "ISO/TC211", "fetched" => Date.today.to_s,
        "titles" => [
          "Geographic information",
          #{ "type" => "main", "content" => "Geographic information", "language" => "en", "script" => "Latn" },
          {
            "content" => "Information géographique", "language" => "fr", "script" => "Latn"
          },
        ],
        "type" => "standard",
        "docid" => [ { "id" => "TC211", "type" => "ISO" } ],
        "docnumber" => "123456",
        "edition" => "1", "language" => %w[en fr], "script" => ["Latn"],
        "version" => { "revision_date" => "2019-04-01", "draft" => ["draft"]},
        "biblionote" => [ { "content" => "note", "type" => "bibnote" } ],
        "docstatus" => {
          "stage" => "stage", "substage" => "substage", "iteration" => "final",
        },
        "dates" => [
          { "type" => "issued", "value" => "2014" },
          { "type" => "published", "on" => "2014-04" },
          { "type" => "accessed", "on" => "2015-05-20" },
        ],
        "abstract" => [
          { "content" => "ISO 19115-1:2014 defines the schema required for ...",
            "language" => "en", "script" => "Latn", "format" => "text/plain" },
          { "content" => "L'ISO 19115-1:2014 définit le schéma requis pour ...",
            "language" => "fr", "script" => "Latn", "format" => "text/plain" },
        ],
        "contributors" => [
          {
            "entity" => {
              "name" => "International Organization for Standardization",
              "url" => "www.iso.org", "abbreviation" => "ISO", "subdivision" => "division",
            },
            "roles" => [["publisher", ["Publisher role"]]],
          },
          {
            "entity" => {
              "name" => {
                "completename" => {
                  "content" => "A. Bierman",
                  "language" => "en"
                }
              },
              "affiliation" => [{
                "organization" => {
                  "name" => "IETF",
                  "abbreviation" => "IETF",
                  "identifiers" => [{"type" => "uri", "id" => "www.ietf.org"}],
                }
              }],
              "contacts" => [
                {
                  "street" => ["Street"], "city" => "City", "postcode" => "123456",
                  "country" => "Country", "state" => "State"
                },
                {"type" => "phone", "value" => "223322"},
              ]
            },
            "roles" => ["author"],
          },
          {
            "entity" => {
              "name" => "IETF",
              "abbreviation" => "IETF",
              "identifiers" => [{"type" => "uri", "id" => "www.ietf.org"}],
            },
            "roles" => ["publisher"],
          },
          {
            "entity" => {
              "name" => {
                "language" => "en",
                "initials" => ["A."],
                "surname" => "Bierman",
              },
              "affiliation" => [{
                "organization" => {
                "name" => "IETF", "abbreviation" => "IETF",
                }
              }],
              "contacts" => [
                {
                  "street" => ["Street"], "city" => "City", "postcode" => "123456",
                  "country" => "Country", "state" => "State"
                },
                {"type" => "phone", "value" => "223322"},
              ],
              "identifiers" => [{"type" => "uri", "id" => "www.person.com"}],
            },
            "roles" => ["author"],
          },
        ],
        "copyright" => { "owner" => {
          "name" => "International Organization for Standardization",
          "abbreviation" => "ISO", "url" => "www.iso.org"
        }, "from" => "2014", "to" => "2020" },
        "link" => [
          { "type" => "src", "content" => "https://www.iso.org/standard/53798.html" },
          { "type" => "obp",
            "content" => "https://www.iso.org/obp/ui/#!iso:std:53798:en" },
          { "type" => "rss", "content" => "https://www.iso.org/contents/data/standard"\
            "/05/37/53798.detail.rss" },
        ],
        "relations" => [
          {
            "type" => "updates",
            "bibitem" => {
              "formattedref" => "ISO 19115:2003",
            },
            "bib_locality" => [
              {"type" => "updates", "reference_from" => "Reference form"},
            ],
          },
          {
            "type" => "updates",
            "bibitem" => {
              "type" => "standard",
              "formattedref" => "ISO 19115:2003/Cor 1:2006",
            },
          },
        ],
        "series" => [
          {
            "type" => "main",
            "title" => {
              "type" => "original", "content" => "ISO/IEC FDIS 10118-3", "language" => "en",
              "script" => "Latn", "format" => "text/plain",
            },
            "place" => "Serie's place",
            "organization" => "Serie's organization",
            "abbreviation" => {"content" => "ABVR", "language" => "en", "script" => "Latn"},
            "from" => "2009-02-01",
            "to" => "2010-12-20",
            "number" => "serie1234",
            "partnumber" => "part5678",
          },
          {
            "type" => "alt",
            "formattedref" => {
              "content" => "serieref", "language" => "en", "script" => "Latn",
            },
          }
        ],
        "medium" => {
          "form" => "medium form", "size" => "medium size", "scale" => "medium scale",
        },
        "place" => ["bib place"],
        "extent" => [
          {
            "type" => "section", "reference_from" => "Reference from", "reference_to" => "Reference to"
          },
        ],
        "accesslocation" => ["accesslocation1", "accesslocation2"],
        "classification" => {"type" => "type", "value" => "value"},
        "validity" => {
          "begins" => "2010-10-10 12:21",
          "ends" => "2011-02-03 18:30",
          "revision" => "2011-03-04 09:00",
        }
    }

RSpec.describe "RelatonBib" =>:BibliographicItem do
  context "instance" do
    subject do
    item = {
        id: "ISO/TC211", fetched: Date.today.to_s,
        titles: [
          { type: "main", content: "Geographic information", language: "en", script: "Latn" },
          {
            content: "Information géographique", language: "fr", script: "Latn"
          },
        ],
        type: "standard",
        docid: [
          RelatonBib::DocumentIdentifier.new(id: "TC211", type: "ISO"),
        ],
        docnumber: "123456",
        edition: "1", language: %w[en fr], script: ["Latn"],
        version: RelatonBib::BibliographicItem::Version.new("2019-04-01", ["draft"]),
        biblionote: [
          RelatonBib::BiblioNote.new(content: "note", type: "bibnote"),
        ],
        docstatus: RelatonBib::DocumentStatus.new(
          stage: "stage", substage: "substage", iteration: "final",
        ),
        dates: [
          { type: "issued", on: "2014" },
          { type: "published", on: "2014-04" },
          { type: "accessed", on: "2015-05-20" },
        ],
        abstract: [
          { content: "ISO 19115-1:2014 defines the schema required for ...",
            language: "en", script: "Latn", format: "text/plain" },
          { content: "L'ISO 19115-1:2014 définit le schéma requis pour ...",
            language: "fr", script: "Latn", format: "text/plain" },
        ],
        contributors: [
          {
            entity: {
              name: "International Organization for Standardization",
              url: "www.iso.org", abbreviation: "ISO", subdivision: "division",
            },
            roles: [["publisher", ["Publisher role"]]],
          },
          {
            entity: RelatonBib::Person.new(
              name: RelatonBib::FullName.new(
                completename: localized_string("A. Bierman"),
              ),
              affiliation: [RelatonBib::Affilation.new(
                RelatonBib::Organization.new(
                  name: "IETF",
                  abbreviation: RelatonBib::LocalizedString.new("IETF"),
                  identifiers: [RelatonBib::OrgIdentifier.new("uri", "www.ietf.org")],
                )
              )],
              contacts: [
                RelatonBib::Address.new(
                  street: ["Street"], city: "City", postcode: "123456",
                  country: "Country", state: "State"
                ),
                RelatonBib::Contact.new(type: "phone", value: "223322"),
              ]
            ),
            roles: ["author"],
          },
          RelatonBib::ContributionInfo.new(
            entity: RelatonBib::Organization.new(
              name: "IETF",
              abbreviation: "IETF",
              identifiers: [RelatonBib::OrgIdentifier.new("uri", "www.ietf.org")],
            ),
            role: ["publisher"],
          ),
          {
            entity: RelatonBib::Person.new(
              name: RelatonBib::FullName.new(
                initials: [localized_string("A.")],
                surname: localized_string("Bierman"),
              ),
              affiliation: [RelatonBib::Affilation.new(
                RelatonBib::Organization.new(name: "IETF", abbreviation: "IETF"),
              )],
              contacts: [
                RelatonBib::Address.new(
                  street: ["Street"], city: "City", postcode: "123456",
                  country: "Country", state: "State"
                ),
                RelatonBib::Contact.new(type: "phone", value: "223322"),
              ],
              identifiers: [RelatonBib::PersonIdentifier.new("uri", "www.person.com")],
            ),
            roles: ["author"],
          },
        ],
        copyright: { owner: {
          name: "International Organization for Standardization",
          abbreviation: "ISO", url: "www.iso.org"
        }, from: "2014", to: "2020" },
        link: [
          { type: "src", content: "https://www.iso.org/standard/53798.html" },
          { type: "obp",
            content: "https://www.iso.org/obp/ui/#!iso:std:53798:en" },
          { type: "rss", content: "https://www.iso.org/contents/data/standard"\
            "/05/37/53798.detail.rss" },
        ],
        relations: [
          {
            type: "updates",
            bibitem: RelatonBib::BibliographicItem.new(
              formattedref: RelatonBib::FormattedRef.new(content: "ISO 19115:2003"),
            ),
            bib_locality: [
              RelatonBib::BibItemLocality.new("updates", "Reference form"),
            ],
          },
          {
            type: "updates",
            bibitem: RelatonBib::BibliographicItem.new(
              type: "standard",
              formattedref: RelatonBib::FormattedRef.new(content: "ISO 19115:2003/Cor 1:2006"),
            ),
          },
        ],
        series: [
          RelatonBib::Series.new(
            type: "main",
            title: RelatonBib::TypedTitleString.new(
              type: "original", content: "ISO/IEC FDIS 10118-3", language: "en",
              script: "Latn", format: "text/plain",
            ),
            place: "Serie's place",
            organization: "Serie's organization",
            abbreviation: RelatonBib::LocalizedString.new("ABVR", "en", "Latn"),
            from: "2009-02-01",
            to: "2010-12-20",
            number: "serie1234",
            partnumber: "part5678",
          ),
          RelatonBib::Series.new(
            type: "alt",
            formattedref: RelatonBib::FormattedRef.new(
              content: "serieref", language: "en", script: "Latn",
            ),
          )
        ],
        medium: RelatonBib::Medium.new(
          form: "medium form", size: "medium size", scale: "medium scale",
        ),
        place: ["bib place"],
        extent: [
          RelatonBib::BibItemLocality.new(
            "section", "Reference from", "Reference to"
          ),
        ],
        accesslocation: ["accesslocation1", "accesslocation2"],
        classification: RelatonBib::Classification.new(type: "type", value: "value"),
        validity: RelatonBib::Validity.new(
          begins: Time.new(2010, 10, 10, 12, 21),
          ends: Time.new(2011, 2, 3, 18,30),
          revision: Time.new(2011, 3, 4, 9, 0)
        )
    }

      RelatonBib::BibliographicItem.new(item)
    end

    it "is instance of BibliographicItem" do
      expect(subject).to be_instance_of RelatonBib::BibliographicItem
    end

    it "has array of titiles" do
      expect(subject.title).to be_instance_of Array
    end

    it "returns shortref" do
      expect(subject.shortref(subject.docidentifier.first)).to eq "TC211:2014"
    end

    it "returns abstract with en language" do
      expect(subject.abstract(lang: "en")).to be_instance_of RelatonBib::FormattedString
    end

    it "returns xml string" do
      file = "spec/examples/bib_item.xml"
      File.write file, subject.to_xml, encoding: "utf-8" unless File.exist? file
      xml = File.read(file, encoding: "utf-8").gsub(
        /<fetched>\d{4}-\d{2}-\d{2}/, "<fetched>#{Date.today}"
      )
      expect(subject.to_xml).to be_equivalent_to xml
    end

    it "render addition elements" do
      expect(subject.to_xml { |b| b.element "test" }).to include "<element>test</element>"
    end

    it "deals with hashes" do
      h = RelatonBib::hash_to_bib(item_hash)
      b = RelatonBib::BibliographicItem.new(h)
      expect(b.to_xml).to be_equivalent_to subject.to_xml
    end

  end

  it "initialize with copyright object" do
    org = RelatonBib::Organization.new(
      name: "Test Org", abbreviation: "TO", url: "test.org",
    )
    owner = RelatonBib::ContributionInfo.new entity: org
    bibitem = RelatonBib::BibliographicItem.new(
      formattedref: RelatonBib::FormattedRef.new(content: "ISO123"),
      copyright: RelatonBib::CopyrightAssociation.new(owner: owner, from: "2018"),
    )
    expect(bibitem.to_xml).to include "<formattedref format=\"text/plain\">ISO123</formattedref>"
  end

  it "raises invalid type argument error" do
    expect { RelatonBib::BibliographicItem.new type: "type" }.to raise_error ArgumentError
  end

  context RelatonBib::CopyrightAssociation do
    it "initialise with owner object" do
      org = RelatonBib::Organization.new(
        name: "Test Org", abbreviation: "TO", url: "test.org",
      )
      owner = RelatonBib::ContributionInfo.new entity: org
      copy = RelatonBib::CopyrightAssociation.new owner: owner, from: "2019"
      expect(copy.owner).to be owner
    end
  end

  private

  # @param content [String]
  # @return [IsoBibItem::LocalizedString]
  def localized_string(content, lang = "en")
    RelatonBib::LocalizedString.new(content, lang)
  end
end
