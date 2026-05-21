# === expected ===
# cassettes:
#   - pattern: "prefix_*"
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "unresolved interpolation parts collapse to a wildcard" do
    VCR.use_cassette("prefix_#{SomeCall.value}") { }
  end
end
