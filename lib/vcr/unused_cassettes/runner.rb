# frozen_string_literal: true

module VCR::UnusedCassettes
  class Runner
    def find_unused_cassettes
      cassettes = Dir.glob(path_for_cassette("*"))
      cassette_uses, warnings = used_cassettes_names_patterns
      cassette_uses.map! { |pattern| path_for_cassette(pattern) }

      unused_cassettes = cassettes.select do |existing_cassette_name|
        !cassette_uses.any? { |used_cassette_name| File.fnmatch?(used_cassette_name, existing_cassette_name) }
      end
      [unused_cassettes, warnings]
    end

    def used_cassettes_names_patterns
      used_cassettes = []
      warnings = []
      ["test", "spec"].each do |test_folder|
        `grep -n '#{CodeFragments::UseCassetteFragment::SNIPPET}' #{test_folder}/**/*.rb`.split("\n").each do |line|
          used_cassette_fragment = CodeFragments::UseCassetteFragment.new(*line.split(":", 3))
          used_cassette_fragment.strip_comments!
          # was the snippet only in the comment?
          next unless used_cassette_fragment.snippet_present?

          cassette_name = used_cassette_fragment.find_cassette_name
          if cassette_name
            used_cassettes << cassette_name
          else
            warnings << "Could not determine cassette name in #{used_cassette_fragment.file}:#{used_cassette_fragment.line_number}"
          end
        end
      end

      [used_cassettes, warnings]
    end
  end

  def path_for_cassette(cassette_name)
    VCR::Cassette.new(cassette_name).file
  end
end
