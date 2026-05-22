# === expected ===
# cassettes:
#   - pattern: cassette_default
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "relies on the helper's default keyword value" do
    helper
  end

  private def helper(cassette: "cassette_default")
    VCR.use_cassette(cassette) { }
  end
end
