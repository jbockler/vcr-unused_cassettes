# === expected ===
# cassettes: []
# warnings: 1
# === end ===

class FooTest < Minitest::Test
  private def helper(cassette:)
    VCR.use_cassette(cassette) { }
  end
end
