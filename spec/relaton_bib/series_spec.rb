# frozen_string_literal: true

require "relaton_bib/series"

RSpec.describe RelatonBib::Series do
  it "raise argument error when title argument missed" do
    expect { RelatonBib::Series.new }.to raise_error ArgumentError
  end
end
