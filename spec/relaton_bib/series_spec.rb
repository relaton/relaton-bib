# frozen_string_literal: true

RSpec.describe RelatonBib::Series do
  it "raise argument error when title argument missed" do
    expect { RelatonBib::Series.new }.to raise_error ArgumentError
  end

  it "raises invalid type atgument error" do
    expect do
      RelatonBib::Series.new title: RelatonBib::TypedTitleString.new(content: "title"), type: "type"
    end.to raise_error ArgumentError
  end
end
