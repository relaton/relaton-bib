RSpec.describe RelatonBib::BibtexParser do
  it "parse BibTex" do
    items = RelatonBib::BibtexParser.from_bibtex <<~BIBTEX
      @article{mrx05,
        type = "standard",
        auTHor = "Mr. X and Y, Mr.",
        editor = {Mr. Z},
        address = {Some address},
        Title = {Something Great},
        publisher = "nobody",
        YEAR = 2005,
        month = 5,
        annote = {An Note},
        booktitle = {Book title},
        chapter = 4,
        edition = 2,
        howpublished = {How Published Note},
        institution = {Institution},
        journal = {Journal},
        note = {Note},
        number = 7,
        series = {Series},
        type = {Type},
        organization = {Organization},
        pages = {10-20},
        school = {School},
        volume = 1,
        urldate = {2019-12-11},
        timestamp = {2019-12-05 13:52:43},
        doi = {http://standard.org/doi-123},
        comment = {Comment},
        isbn = {isbnId},
        keywords = {Keyword, Key Word},
        language = {english},
        lccn = {lccnId},
        file2 = {file://path/file},
        mendeley-tags = {Mendeley tags},
        url = {http://standars.org/123},
        issn = {issnId},
        subtitle = {Sub title},
        content = {Content}
      },
      @mastersthesis{mrx06,
        type = "standard",
        auTHor = "Mr. X",
        address = {Some address},
        Title = {Something Great},
        publisher = "nobody",
        YEAR = 2005,
      },
      @misc{mrx07,
        type = "standard",
        auTHor = "Mr. X",
        address = {Some address},
        Title = {Something Great},
        publisher = "nobody",
        YEAR = 2005,
      },
      @conference{mrx08,
        type = "standard",
        auTHor = "Mr. X",
        address = {Some address},
        Title = {Something Great},
        publisher = "nobody",
        YEAR = 2005,
      }
    BIBTEX
    expect(items).to be_instance_of Hash
    expect(items["mrx05"]).to be_instance_of RelatonBib::BibliographicItem

    file = "spec/examples/from_bibtex.xml"
    xml = items["mrx05"].to_xml
    File.write(file, xml, encoding: "utf-8") unless File.exist? file
    expect(xml).to be_equivalent_to File.read(file, encoding: "utf-8")
  end

  context "parse title" do
    it "with subtitle" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          title = {Something Great},
          subtitle = {Sub title},
        }
      BIBTEX
      title = described_class.send :fetch_title, bibtex["mrx05"]
      expect(title[0].title.content).to eq "Something Great"
      expect(title[1].title.content).to eq "Sub title"
    end

    it "with double curly braces" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          title = {{Something Great}},
        }
      BIBTEX
      title = described_class.send :fetch_title, bibtex["mrx05"]
      expect(title[0].title.content).to eq "Something Great"
    end
  end

  context "parse contributor" do
    it "howpublished" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
        howpublished = "\\publisher{Taylor {\\&} Francis},\\url{http://www.tandfonline.com/doi/abs/10.1080/17538940802439549}"
        }
      BIBTEX
      contribs = described_class.send :fetch_contributor, bibtex["mrx05"]
      expect(contribs[0][:entity]).to be_instance_of RelatonBib::Organization
      expect(contribs[0][:entity].name[0].content).to eq "Taylor & Francis"
      expect(contribs[0][:role][0][:type]).to eq "publisher"
    end
  end

  context "parse note" do
    it "with howpublished as note" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          howpublished = {How Published Note},
        }
      BIBTEX
      note = described_class.send :fetch_note, bibtex["mrx05"]
      expect(note).to be_instance_of RelatonBib::BiblioNoteCollection
      expect(note[0]).to be_instance_of RelatonBib::BiblioNote
      expect(note[0].type).to eq "howpublished"
      expect(note[0].content).to eq "How Published Note"
    end

    it "don't parse howpublished as note" do
      bibtex = <<~BIBTEX
        @article{mrx05,
          howpublished = "\\publisher{Taylor {\&} Francis},\\url{http://www.tandfonline.com/doi/abs/10.1080/17538940802439549}"
        }
      BIBTEX
      docs = BibTeX.parse bibtex
      note = described_class.send :fetch_note, docs["mrx05"]
      expect(note).to be_instance_of RelatonBib::BiblioNoteCollection
      expect(note).to be_empty
    end
  end

  context "parse keywords" do
    it "with comma separator" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          keywords = {Sensor Web,data acquisition},
        }
      BIBTEX
      keywords = described_class.send :fetch_keyword, bibtex["mrx05"]
      expect(keywords).to eq %w[Sensor\ Web data\ acquisition]
    end

    it "with comma and space separator" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          keywords = {Sensor Web, data acquisition},
        }
      BIBTEX
      keywords = described_class.send :fetch_keyword, bibtex["mrx05"]
      expect(keywords).to eq %w[Sensor\ Web data\ acquisition]
    end

    it "empty" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
        }
      BIBTEX
      keywords = described_class.send :fetch_keyword, bibtex["mrx05"]
      expect(keywords).to eq []
    end
  end
end
