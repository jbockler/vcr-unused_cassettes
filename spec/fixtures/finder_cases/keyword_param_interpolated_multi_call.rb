# === expected ===
# cassettes:
#   - pattern: prefix_a_1
#   - pattern: prefix_a_2
#   - pattern: prefix_b_1
#   - pattern: prefix_b_2
# warnings: 0
# === end ===

# Cartesian product: runtime uses only prefix_a_1 and prefix_b_2, but the analyzer
# over-approximates per-call-site correlation. Conservative, not unsound.
class FooTest < Minitest::Test
  test "first variant" do
    helper(prefix: "prefix_a", suffix: 1)
  end

  test "second variant" do
    helper(prefix: "prefix_b", suffix: 2)
  end

  private def helper(prefix:, suffix:)
    VCR.use_cassette("#{prefix}_#{suffix}") { }
  end
end
