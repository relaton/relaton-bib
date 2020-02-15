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
end
