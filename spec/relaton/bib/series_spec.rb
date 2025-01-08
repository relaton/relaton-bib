# frozen_string_literal: true

describe Relaton::Bib::Series do
  xit "raise argument error when title argument missed" do
    expect { described_class.new }.to raise_error ArgumentError
  end

  xit "raises invalid type atgument error" do
    expect do
      title = Relaton::Bib::Title.new(content: "title")
      described_class.new title: title, type: "type"
    end.to output(/Series type is invalid: type/).to_stderr
  end
end
