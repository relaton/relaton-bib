describe Relaton::Bib::Converter::Bibtex::ToBibtex do
  context "instance methods" do
    subject { described_class.new bibitem }
    let(:item) { double "item" }
    before { subject.instance_variable_set :@item, item }

    context "add_date" do
      let(:bibitem) { Relaton::Bib::ItemData.new date: [date] }
      let(:date) { Relaton::Bib::Date.new type: "accessed", at: "2019-01-01" }
      it do
        expect(item).to receive(:urldate=).with("2019-01-01")
        subject.send(:add_date)
      end
    end

    context "add_note" do
      let(:bibitem) { Relaton::Bib::ItemData.new note: [note] }

      context "annote" do
        let(:note) { Relaton::Bib::Note.new type: "annote", content: "Note" }
        it do
          expect(item).to receive(:annote=).with("Note")
          subject.send(:add_note)
        end
      end

      context "howpublished" do
        let(:note) { Relaton::Bib::Note.new type: "howpublished", content: "Note" }
        it do
          expect(item).to receive(:howpublished=).with("Note")
          subject.send(:add_note)
        end
      end

      context "comment" do
        let(:note) { Relaton::Bib::Note.new type: "comment", content: "Note" }
        it do
          expect(item).to receive(:comment=).with("Note")
          subject.send(:add_note)
        end
      end

      context "tableOfContents" do
        let(:note) { Relaton::Bib::Note.new type: "tableOfContents", content: "Note" }
        it do
          expect(item).to receive(:content=).with("Note")
          subject.send(:add_note)
        end
      end

      context "no type" do
        let(:note) { Relaton::Bib::Note.new content: "Note" }
        it do
          expect(item).to receive(:note=).with("Note")
          subject.send(:add_note)
        end
      end
    end

    context "add_relation" do
      let(:bibitem) { Relaton::Bib::ItemData.new relation: [relation] }
      let(:relation) { Relaton::Bib::Relation.new type: "partOf", bibitem: bibitem2 }
      let(:bibitem2) { Relaton::Bib::ItemData.new title: [title] }
      let(:title) { Relaton::Bib::Title.new type: "main", content: "Title" }

      it do
        expect(item).to receive(:booktitle=).with("Title")
        subject.send(:add_relation)
      end
    end

    context "add_classification" do
      let(:bibitem) { Relaton::Bib::ItemData.new classification: [docid]}

      context "type" do
        let(:docid) { Relaton::Bib::Docidentifier.new type: "type", content: "ISO 123"}

        it do
          expect(item).to receive(:[]=).with("type", "ISO 123")
          subject.send(:add_classification)
        end
      end

      context "mendeley" do
        let(:docid) { Relaton::Bib::Docidentifier.new type: "mendeley", content: "ISO 2233" }

        it do
          expect(item).to receive(:[]=).with("mendeley-tags", "ISO 2233")
          subject.send(:add_classification)
        end
      end
    end

    context "add_docidentifier" do
      let(:bibitem) { Relaton::Bib::ItemData.new docidentifier: [docid] }

      context "isbn" do
        let(:docid) { Relaton::Bib::Docidentifier.new type: "isbn", content: "978-3-16-148410-0" }

        it do
          expect(item).to receive(:isbn=).with("978-3-16-148410-0")
          subject.send(:add_docidentifier)
        end
      end

      context "issn" do
        let(:docid) { Relaton::Bib::Docidentifier.new type: "lccn", content: "2004041234" }

        it do
          expect(item).to receive(:lccn=).with("2004041234")
          subject.send(:add_docidentifier)
        end
      end

      context "issn" do
        let(:docid) { Relaton::Bib::Docidentifier.new type: "issn", content: "1234-5678" }

        it do
          expect(item).to receive(:issn=).with("1234-5678")
          subject.send(:add_docidentifier)
        end
      end
    end

    context "add_extent" do
      context "sets volume from locality" do
        let(:bibitem) { Relaton::Bib::ItemData.new extent: [extent] }
        let(:extent) { Relaton::Bib::Extent.new(locality: [Relaton::Bib::Locality.new(type: "volume", reference_from: "1")]) }
        it do
          expect(item).to receive(:volume=).with("1")
          subject.send(:add_extent)
        end
      end

      context "sets issue from locality" do
        let(:bibitem) { Relaton::Bib::ItemData.new extent: [extent] }
        let(:extent) { Relaton::Bib::Extent.new(locality: [Relaton::Bib::Locality.new(type: "issue", reference_from: "2")]) }
        it do
          expect(item).to receive(:issue=).with("2")
          subject.send(:add_extent)
        end
      end

      context "sets chapter from locality" do
        let(:bibitem) { Relaton::Bib::ItemData.new extent: [extent] }
        let(:extent) { Relaton::Bib::Extent.new(locality: [Relaton::Bib::Locality.new(type: "chapter", reference_from: "3")]) }
        it do
          expect(item).to receive(:chapter=).with("3")
          subject.send(:add_extent)
        end
      end

      context "sets pages with range" do
        let(:bibitem) { Relaton::Bib::ItemData.new extent: [extent] }
        let(:extent) { Relaton::Bib::Extent.new(locality: [Relaton::Bib::Locality.new(type: "page", reference_from: "3", reference_to: "10")]) }
        it do
          expect(item).to receive(:pages=).with("3--10")
          subject.send(:add_extent)
        end
      end

      context "sets pages without range" do
        let(:bibitem) { Relaton::Bib::ItemData.new extent: [extent] }
        let(:extent) { Relaton::Bib::Extent.new(locality: [Relaton::Bib::Locality.new(type: "page", reference_from: "5")]) }
        it do
          expect(item).to receive(:pages=).with("5")
          subject.send(:add_extent)
        end
      end

      context "processes locality_stack" do
        let(:bibitem) { Relaton::Bib::ItemData.new extent: [extent] }
        let(:extent) do
          e = Relaton::Bib::Extent.new(locality_stack: [
            Relaton::Bib::LocalityStack.new(locality: [
              Relaton::Bib::Locality.new(type: "chapter", reference_from: "5"),
            ]),
          ])
          e.locality = nil
          e
        end
        it do
          expect(item).to receive(:chapter=).with("5")
          subject.send(:add_extent)
        end
      end
    end

    context "add_link" do
      let(:bibitem) { Relaton::Bib::ItemData.new source: source }

      context "ignore links without type" do
        let(:source) { [Relaton::Bib::Uri.new(content: "http://example.com")] }

        it do
          expect(item).not_to receive :doi=
          expect(item).not_to receive :url=
          expect(item).not_to receive :file2=
          subject.send(:add_link)
        end
      end

      context "add doi" do
        let(:source) { [Relaton::Bib::Uri.new(type: "doi", content: "10.1000/xyz123")] }

        it do
          expect(item).to receive(:doi=).with("10.1000/xyz123")
          subject.send(:add_link)
        end
      end

      context "add file2" do
        let(:source) { [Relaton::Bib::Uri.new(type: "file", content: "http://example.com/file.pdf")] }

        it do
          expect(item).to receive(:file2=).with("http://example.com/file.pdf")
          subject.instance_variable_set :@item, item
          subject.send(:add_link)
        end
      end
    end
  end

  it "render article" do
    item = Relaton::Bib::Item.from_xml File.read("spec/fixtures/bibtex_article.xml", encoding: "UTF-8")
    expect(item.to_bibtex).to eq <<~"OUTPUT"
      @article{DOC123,
        title = {Miscellaneous},
        author = {Doe, John and Brown, Mike},
        journal = {Journal of Miscellaneous},
        number = {1},
        year = {2019},
        volume = {1},
        issue = {2},
        pages = {3--4}
      }
    OUTPUT
  end

  it "render book, rpoceedings" do
    bibitem = Relaton::Bib::Item.from_xml File.read("spec/fixtures/bibtex_book.xml", encoding: "UTF-8")
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
    bibitem = Relaton::Bib::Item.from_xml File.read("spec/fixtures/bibtex_inbook.xml", encoding: "UTF-8")
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
    bibitem = Relaton::Bib::Item.from_xml File.read("spec/fixtures/bibtex_inproceedings.xml", encoding: "UTF-8")
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
    bibitem = Relaton::Bib::Item.from_xml File.read("spec/fixtures/bibtex_phdthesis.xml", encoding: "UTF-8")
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
    bibitem = Relaton::Bib::Item.from_xml File.read("spec/fixtures/bibtex_techreport.xml", encoding: "UTF-8")
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

  it "render standard" do
    bibitem = Relaton::Bib::Item.from_yaml File.read("spec/fixtures/item.yaml", encoding: "UTF-8")
    expect(bibitem.to_bibtex).to eq <<~"OUTPUT"
      @misc{ISO1231994,
        title = {Geographic information -- Metadata},
        author = {Doe, John},
        edition = {First edition},
        publisher = {International Organization for Standardization},
        year = {1994},
        month = {jan},
        address = {Geneva, Switzerland, Geneva, Geneva},
        pages = {1--10},
        keywords = {information},
        timestamp = {2022-05-02},
        url = {https://www.iso.org/standard/22722.html},
        doi = {10.1007/978-3-319-99155-2_1},
        month_numeric = {1}
      }
    OUTPUT
  end
end
