# === expected ===
# cassettes:
#   - pattern: cassette_a
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "uses a cassette named via a local variable" do
    name = "cassette_a"
    VCR.use_cassette(name) { }
  end
end
