# === expected ===
# cassettes:
#   - pattern: prefix_cassette_a
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "interpolates a local variable into the cassette name" do
    name = "cassette_a"
    VCR.use_cassette("prefix_#{name}") { }
  end
end
