# frozen_string_literal: true

require "spec_helper"

RSpec.describe VCR::UnusedCassettes::CassetteUsageFinder do
  fixture_dir = File.expand_path("../../fixtures/finder_cases", __dir__)
  fixture_paths = Dir[File.join(fixture_dir, "*.rb")].sort

  if fixture_paths.empty?
    raise "No fixtures found in #{fixture_dir} — at least one fixture is required."
  end

  fixture_paths.each do |fixture_path|
    fixture = FixtureLoader.read(fixture_path)

    describe fixture.name do
      it "extracts the expected cassettes and warning count" do
        cassettes, warnings = described_class.new(fixture.path).find_cassette_usages

        expect(cassettes).to match_array(fixture.expected_cassettes)
        expect(warnings.size).to eq(fixture.expected_warnings)
      end
    end
  end
end
