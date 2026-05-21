# === expected ===
# cassettes:
#   - pattern: cassette_a
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  CASSETTE = "cassette_a"

  test "uses a cassette named via a class-level constant" do
    VCR.use_cassette(CASSETTE) { }
  end
end
