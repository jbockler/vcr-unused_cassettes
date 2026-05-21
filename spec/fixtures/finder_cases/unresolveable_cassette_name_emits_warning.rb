# === expected ===
# cassettes: []
# warnings: 1
# === end ===

class FooTest < Minitest::Test
  test "an unresolveable cassette name is skipped and recorded as a warning" do
    VCR.use_cassette(SomeCall.value) { }
  end
end
