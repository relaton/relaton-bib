# frozen_string_literal: true

RSpec.describe RelatonBib::Series do
  it "raise argument error when title argument missed" do
    expect { RelatonBib::Series.new }.to raise_error ArgumentError
  end

  # it "raises invalid type atgument error" do
  #   expect do
  #     title = RelatonBib::TypedTitleString.new(content: "title")
  #     RelatonBib::Series.new title: title, type: "type"
  #   end.to output(/Series type is invalid: type/).to_stderr
  # end
end
