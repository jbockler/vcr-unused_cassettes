# === expected ===
# cassettes:
#   - pattern: cassette_a
#     persister: :my_persister
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "passes a custom :persist_with through as :persister" do
    VCR.use_cassette("cassette_a", persist_with: :my_persister) { }
  end
end
