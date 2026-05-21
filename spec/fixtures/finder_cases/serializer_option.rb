# === expected ===
# cassettes:
#   - pattern: cassette_a
#     serializer: :json
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "passes a custom :serialize_with through as :serializer" do
    VCR.use_cassette("cassette_a", serialize_with: :json) { }
  end
end
