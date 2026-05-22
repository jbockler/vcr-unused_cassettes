# === expected ===
# cassettes:
#   - pattern: prefix_a_1
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "interpolated parameters resolve to a literal when a single call site is known" do
    helper(prefix: "prefix_a", suffix: 1)
  end

  private def helper(prefix:, suffix:)
    VCR.use_cassette("#{prefix}_#{suffix}") { }
  end
end
