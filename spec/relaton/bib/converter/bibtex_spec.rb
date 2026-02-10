describe Relaton::Bib::Converter::Bibtex do
  it "parse BibTex" do
    items = described_class.to_item <<~BIBTEX
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
    expect(items["mrx05"]).to be_instance_of Relaton::Bib::ItemData

    file = "spec/fixtures/from_bibtex.xml"
    xml = items["mrx05"].to_xml
    File.write(file, xml, encoding: "utf-8") unless File.exist? file
    expect(xml).to be_equivalent_to File.read(file, encoding: "utf-8")
  end

  context "parse title" do
    let(:from_bibtex_class) { Relaton::Bib::Converter::Bibtex::FromBibtex }

    it "with subtitle" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          title = {Something Great},
          subtitle = {Sub title},
        }
      BIBTEX
      title = from_bibtex_class.new(bibtex["mrx05"]).send(:fetch_title)
      expect(title[0].content).to eq "Something Great"
      expect(title[1].content).to eq "Sub title"
    end

    it "with double curly braces" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          title = {{Something Great}},
        }
      BIBTEX
      title = from_bibtex_class.new(bibtex["mrx05"]).send(:fetch_title)
      expect(title[0].content).to eq "Something Great"
    end
  end

  context "parse contributor" do
    let(:from_bibtex_class) { Relaton::Bib::Converter::Bibtex::FromBibtex }

    it "howpublished" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
        howpublished = "\\publisher{Taylor {\\&} Francis},\\url{http://www.tandfonline.com/doi/abs/10.1080/17538940802439549}"
        }
      BIBTEX
      contribs = from_bibtex_class.new(bibtex["mrx05"]).send(:fetch_contributor)
      expect(contribs[0]).to be_instance_of Relaton::Bib::Contributor
      expect(contribs[0].organization.name[0].content).to eq "Taylor & Francis"
      expect(contribs[0].role[0].type).to eq "publisher"
    end
  end

  context "parse note" do
    let(:from_bibtex_class) { Relaton::Bib::Converter::Bibtex::FromBibtex }

    it "with howpublished as note" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          howpublished = {How Published Note},
        }
      BIBTEX
      note = from_bibtex_class.new(bibtex["mrx05"]).send(:fetch_note)
      expect(note).to be_a Array
      expect(note[0]).to be_instance_of Relaton::Bib::Note
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
      note = from_bibtex_class.new(docs["mrx05"]).send(:fetch_note)
      expect(note).to be_a Array
      expect(note).to be_empty
    end
  end

  context "parse keywords" do
    let(:from_bibtex_class) { Relaton::Bib::Converter::Bibtex::FromBibtex }

    it "with comma separator" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          keywords = {Sensor Web,data acquisition},
        }
      BIBTEX
      keywords = from_bibtex_class.new(bibtex["mrx05"]).send(:fetch_keyword)
      expect(keywords.map { |k| k.taxon[0].content }).to eq %w[Sensor\ Web data\ acquisition]
    end

    it "with comma and space separator" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
          keywords = {Sensor Web, data acquisition},
        }
      BIBTEX
      keywords = from_bibtex_class.new(bibtex["mrx05"]).send(:fetch_keyword)
      expect(keywords.map { |k| k.taxon[0].content }).to eq %w[Sensor\ Web data\ acquisition]
    end

    it "empty" do
      bibtex = BibTeX.parse <<~BIBTEX
        @article{mrx05,
        }
      BIBTEX
      keywords = from_bibtex_class.new(bibtex["mrx05"]).send(:fetch_keyword)
      expect(keywords).to eq []
    end
  end
end
