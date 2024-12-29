require "spec_helper"

RSpec.describe VCR::UnusedCassettes::CodeFragments::UseCassetteFragment do
  let(:file) { "test.rb" }
  let(:line_number) { 42 }
  let(:content) { "VCR.use_cassette('example_cassette') do" }

  subject { described_class.new(file, line_number, content) }

  describe "#find_cassette_name" do
    it "returns the cassette name" do
      expect(subject.find_cassette_name).to eq("example_cassette")
    end
  end

  describe "#snippet_present?" do
    it "returns true" do
      expect(subject.snippet_present?).to eq(true)
    end
  end

  describe "#snipped_called?" do
    it "returns true" do
      expect(subject.snipped_called?).to eq(true)
    end

    context "when the snippet is in a comment" do
      let(:content) { "# VCR.use_cassette('example_cassette') do" }

      it "returns false" do
        expect(subject.snipped_called?).to eq(false)
      end
    end

    context "temp" do
      let(:content) { 'VCR.use_cassette("#{foo}_bar") do' }

      it "returns true" do
        expect(subject.snipped_called?).to eq(false)
      end
    end
  end
end
