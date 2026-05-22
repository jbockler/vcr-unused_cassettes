# === expected ===
# cassettes:
#   - pattern: cassette_a
#   - pattern: cassette_b
#   - pattern: cassette_c
# warnings: 0
# === end ===

RSpec.describe "rspec-shaped fixture" do
  before do
    @from_before = "cassette_c"
  end

  it "resolves a literal cassette inside it" do
    VCR.use_cassette("cassette_a") { }
  end

  context "with a nested context" do
    it "resets locals between examples" do
      name = "cassette_b"
      VCR.use_cassette(name) { }
    end

    it "preserves instance vars set in before blocks" do
      VCR.use_cassette(@from_before) { }
    end
  end
end
