# === expected ===
# cassettes: []
# warnings: 1
# === end ===

# Locals defined at describe scope do NOT survive the per-example reset
# triggered by entering `it`. This is consistent with how the gem handles
# minitest's `test "..."` boundary. Use `before { @x = ... }` instead.
RSpec.describe "describe-scoped locals do not flow into it" do
  name = "foo"

  it "cannot resolve a describe-scoped local" do
    VCR.use_cassette(name) { }
  end
end
