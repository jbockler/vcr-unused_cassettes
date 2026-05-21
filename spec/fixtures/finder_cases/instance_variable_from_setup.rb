# === expected ===
# cassettes:
#   - pattern: cassette_a
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  def setup
    @cassette = "cassette_a"
  end

  test "instance variables set in setup survive the per-test reset" do
    VCR.use_cassette(@cassette) { }
  end
end
