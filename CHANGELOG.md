## [Unreleased]

- Fix `NoMethodError` when emitting a warning for an unresolveable cassette name
- Resolve cassette names that come from method parameters by binding helper-method parameters to literal defaults and to the values passed at same-file call sites. Multi-value bindings fan out into one cassette entry per value; interpolations fan out via Cartesian product, so patterns like `"#{prefix}_#{suffix}"` resolve to concrete cassettes instead of being flagged as unused.
- Raise on unbound local/instance variable reads instead of silently returning `nil`, so unresolved interpolation parts collapse to `"*"` wildcards rather than producing garbage patterns.
- Add experimental support for rspec: recognize `describe`, `context`, and `it` as example boundaries, and resolve instance variables assigned in `before` blocks. Cassette names defined via `let` / `let!` / `subject` are not resolved, and calls like `VCR.use_cassette(cassette_name)` where `cassette_name` is a `let` helper will emit a warning and may cause the gem to incorrectly report the matching cassette as unused.
- Chore: Add tests

## [1.1.0] - 2025-03-03

- Comply with zeitwerks eager loading

## [1.0.0] - 2025-01-16

Initial release:
- support for minitest
- basic interpretation of variables and constants in the `VCR.use_cassette` call
- support for multiple persisters and serializers
- rake task to check for unused cassettes
- rake tasks to remove unused cassettes
