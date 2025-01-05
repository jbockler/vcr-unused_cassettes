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
      # todo workaround for warnings
      used_cassettes = []
      warnings = []

      file_list = `grep -r -l "VCR.use_cassette" test/`.split("\n")
      return [[], []] if file_list.empty? || $? != 0

      file_list.each do |file|
        found_usages, found_warnings = CassetteUsageFinder.new(file).find_cassette_usages
        used_cassettes += found_usages
        warnings += found_warnings
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
      placeholder = "a_placeholder_that_should_not_exist"
      full_path = path_for_cassette(name.gsub("*", placeholder))
      full_path.sub(placeholder, "*")
    end

    def persister
      @persister ||= begin
        default_persister = VCR.configuration.default_cassette_options[:persist_with]
        VCR.configuration.cassette_persisters[default_persister]
      end
    end
  end
end
