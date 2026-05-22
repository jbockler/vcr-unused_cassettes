# === expected ===
# cassettes:
#   - pattern: cassette_a
#   - pattern: cassette_b
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "uses cassette A" do
    helper(cassette: "cassette_a")
  end

  test "uses cassette B" do
    helper(cassette: "cassette_b")
  end

  private def helper(cassette:)
    VCR.use_cassette(cassette) { }
  end
end
