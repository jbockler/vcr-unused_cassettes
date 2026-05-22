# === expected ===
# cassettes:
#   - pattern: cassette_a
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "passes the cassette name as a positional argument" do
    helper("cassette_a")
  end

  private def helper(cassette)
    VCR.use_cassette(cassette) { }
  end
end
