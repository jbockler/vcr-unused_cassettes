# === expected ===
# cassettes:
#   - pattern: cassette_a
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "uses a literal cassette name" do
    VCR.use_cassette("cassette_a") { }
  end
end
