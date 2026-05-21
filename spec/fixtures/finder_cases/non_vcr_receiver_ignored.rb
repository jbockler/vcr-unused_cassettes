# === expected ===
# cassettes: []
# warnings: 0
# === end ===

class FooTest < Minitest::Test
  test "use_cassette on a non-VCR receiver is not matched" do
    Foo.use_cassette("cassette_a") { }
  end
end
