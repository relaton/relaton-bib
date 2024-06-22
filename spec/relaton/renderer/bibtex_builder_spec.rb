describe Relaton::Renderer::BibtexBuilder do
  context "instance methods" do
    subject { Relaton::Renderer::BibtexBuilder.new bibitem }
    context "add_link" do
      let(:bibitem) { Relaton::Bib::Item.new link: ["http://example.com"] }
      it "ignore links without type" do
        item = double "item"
        expect(item).not_to receive :doi=
        expect(item).not_to receive :url=
        expect(item).not_to receive :file2=
        subject.instance_variable_set :@item, item
        subject.send(:add_link)
      end
    end
  end

  it "render article" do
    bibitem = Relaton::XMLParser.from_xml File.read("spec/examples/bibtex_article.xml")
    expect(bibitem.to_bibtex).to eq <<~"OUTPUT"
      @article{DOC123,
        title = {Miscellaneous},
        author = {Doe, John and Brown, Mike},
        journal = {Journal of Miscellaneous},
        year = {2019},
        volume = {1},
        number = {2},
        pages = {3--4}
      }
    OUTPUT
  end

  it "render book, rpoceedings" do
    bibitem = Relaton::XMLParser.from_xml File.read("spec/examples/bibtex_book.xml")
    expect(bibitem.to_bibtex).to eq <<~"OUTPUT"
      @book{DOC123,
        title = {Title},
        author = {Doe, John and Brown, Mike},
        editor = {Reed, Mark and Rous, Megan},
        series = {Series},
        edition = {2},
        publisher = {Publisher},
        year = {2019},
        address = {New York, NY},
        volume = {1}
      }
    OUTPUT
  end

  it "render inbook, incollection" do
    bibitem = Relaton::XMLParser.from_xml File.read("spec/examples/bibtex_inbook.xml")
    expect(bibitem.to_bibtex).to eq <<~"OUTPUT"
      @inbook{DOC123,
        title = {Title},
        author = {Doe, John and Brown, Mike},
        editor = {Reed, Mark and Rous, Megan},
        booktitle = {Book Title},
        series = {Series},
        edition = {2},
        publisher = {Publisher},
        year = {2019},
        address = {New York, NY},
        volume = {1},
        chapter = {2},
        pages = {3--4}
      }
    OUTPUT
  end

  it "render inproceedings" do
    bibitem = Relaton::XMLParser.from_xml File.read("spec/examples/bibtex_inproceedings.xml")
    expect(bibitem.to_bibtex).to eq <<~"OUTPUT"
      @inproceedings{DOC123,
        title = {Title},
        author = {Doe, John and Brown, Mike},
        editor = {Reed, Mark and Rous, Megan},
        booktitle = {Book Title},
        series = {Series},
        publisher = {Publisher},
        organization = {Distributor},
        year = {2019},
        address = {New York, NY},
        pages = {3--4}
      }
    OUTPUT
  end

  it "render phdthesis" do
    bibitem = Relaton::XMLParser.from_xml File.read("spec/examples/bibtex_phdthesis.xml")
    expect(bibitem.to_bibtex).to eq <<~"OUTPUT"
      @phdthesis{DOC123,
        title = {Title},
        author = {Doe, John and Brown, Mike},
        school = {Distributor},
        year = {2019},
        address = {New York, NY}
      }
    OUTPUT
  end

  it "render techreport" do
    bibitem = Relaton::XMLParser.from_xml File.read("spec/examples/bibtex_techreport.xml")
    expect(bibitem.to_bibtex).to eq <<~"OUTPUT"
      @techreport{DOC123,
        title = {Title},
        author = {Doe, John and Brown, Mike},
        number = {123},
        edition = {2},
        institution = {Distributor},
        year = {2019},
        address = {New York, NY}
      }
    OUTPUT
  end
end
