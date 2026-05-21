# frozen_string_literal: true

require "yaml"

module FixtureLoader
  HEADER_START = "# === expected ==="
  HEADER_END = "# === end ==="

  SYMBOL_KEYS = %i[persister serializer].freeze

  Fixture = Struct.new(:path, :name, :expected_cassettes, :expected_warnings, keyword_init: true)

  def self.read(path)
    lines = File.readlines(path, chomp: true)
    start_idx = lines.index(HEADER_START)
    end_idx = lines.index(HEADER_END)
    if start_idx.nil? || end_idx.nil?
      raise "Fixture #{path} is missing the `#{HEADER_START}` / `#{HEADER_END}` block"
    end

    yaml = lines[(start_idx + 1)...end_idx].map { |line| line.sub(/\A#( |$)/, "") }.join("\n")
    parsed = YAML.safe_load(yaml, permitted_classes: [Symbol]) || {}

    Fixture.new(
      path: path,
      name: File.basename(path, ".rb"),
      expected_cassettes: normalize_cassettes(parsed["cassettes"] || []),
      expected_warnings: parsed["warnings"] || 0
    )
  end

  # Coerce :persister / :serializer values to symbols regardless of how YAML
  # parsed them. Psych parses `:foo` as a Symbol via a Ruby-specific extension;
  # if that ever changes (or we swap parsers), values would arrive as strings.
  def self.normalize_cassettes(entries)
    entries.map do |entry|
      entry.each_with_object({}) do |(k, v), out|
        key = k.to_sym
        out[key] = SYMBOL_KEYS.include?(key) ? v.to_sym : v
      end
    end
  end
end
