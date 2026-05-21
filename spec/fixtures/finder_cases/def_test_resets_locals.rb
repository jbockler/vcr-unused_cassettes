# === expected ===
# cassettes:
#   - pattern: cassette_a
#   - pattern: cassette_b
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  def test_first
    name = "cassette_a"
    VCR.use_cassette(name) { }
  end

  def test_second
    name = "cassette_b"
    VCR.use_cassette(name) { }
  end
end
