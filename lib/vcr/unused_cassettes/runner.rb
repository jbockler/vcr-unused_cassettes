# frozen_string_literal: true

module VCR::UnusedCassettes
  class Runner
    def find_unused_cassettes
      existing_cassettes = find_existing_cassettes
      cassette_uses, warnings = used_cassettes_names_patterns
      cassette_uses.map! { |pattern| cassette_path_with_wildcard(pattern) }

      unused_cassettes = existing_cassettes.select do |existing_cassette_name|
        !cassette_uses.any? { |used_cassette_name| File.fnmatch?(used_cassette_name, existing_cassette_name) }
      end
      [unused_cassettes, warnings]
    end

    def used_cassettes_names_patterns
      used_cassettes = []
      warnings = []
      ["test", "spec"].each do |test_folder|
        next unless File.exist?(test_folder)
        `grep -r -n '#{CodeFragments::UseCassetteFragment::SNIPPET}' #{test_folder}/`.split("\n").each do |line|
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

    def find_existing_cassettes
      Dir.glob(cassette_path_with_wildcard("*"))
    end

    def path_for_cassette(cassette_name)
      result = persister.absolute_path_to_file(cassette_name)
      return result.to_s if result
      raise Error, "Could not determine path for cassette #{cassette_name}"
    end

    def cassette_path_with_wildcard(name)
      placeholder = "example_cassette"
      full_path = path_for_cassette(placeholder)
      name.downcase! if downcase_cassette_names?
      full_path.sub(placeholder, name)
    end

    def downcase_cassette_names?
      !!VCR.configuration
        .default_cassette_options
        .dig(:persister_options, :downcase_cassette_names)
    end

    def persister
      @persister ||= begin
        default_persister = VCR.configuration.default_cassette_options[:persist_with]
        VCR.configuration.cassette_persisters[default_persister]
      end
    end
  end
end
