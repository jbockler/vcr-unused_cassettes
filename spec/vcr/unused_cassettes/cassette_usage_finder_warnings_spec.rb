# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe VCR::UnusedCassettes::CassetteUsageFinder do
  describe "warnings" do
    it "records a warning with the source file path and line number of the failed call" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "snippet.rb")
        File.write(path, <<~RUBY)
          # line 1
          VCR.use_cassette(SomeCall.value) { }
        RUBY

        cassettes, warnings = described_class.new(path).find_cassette_usages

        expect(cassettes).to be_empty
        expect(warnings.size).to eq(1)

        warning = warnings.first
        expect(warning).to be_a(VCR::UnusedCassettes::Warning)
        expect(warning.message).to eq("Could not determine cassette name for #{path}:2")
        expect(warning.details).to include("Could not resolve value for node")
        expect(warning.backtrace).to be_an(Array)
      end
    end
  end
end
