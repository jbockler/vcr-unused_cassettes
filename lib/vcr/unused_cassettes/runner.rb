# frozen_string_literal: true

module VCR::UnusedCassettes
  class Runner
    def find_unused_cassettes
      existing_cassettes = find_existing_cassettes
      cassette_uses, warnings = used_cassettes_names_patterns
      cassette_uses.map! { |cassette_use| path_for_cassette_use(cassette_use) }

      unused_cassettes = existing_cassettes.select do |existing_cassette_name|
        !cassette_uses.any? { |used_cassette_name| File.fnmatch?(used_cassette_name, existing_cassette_name) }
      end

      [unused_cassettes, warnings]
    end

    def used_cassettes_names_patterns
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
      cassettes = []
      all_vcr_persisters.each do |_name, persister|
        cassettes += Dir.glob(cassette_path_with_wildcard("*", persister))
      end
      cassettes.uniq
    end

    def path_for_cassette(cassette_name, persister)
      result = persister.absolute_path_to_file(cassette_name)
      return result.to_s if result
      raise Error, "Could not determine path for cassette #{cassette_name}"
    end

    def cassette_path_with_wildcard(name, persister)
      placeholder = "a_placeholder_that_should_not_exist"
      full_path = path_for_cassette(name.gsub("*", placeholder), persister)
      full_path.sub(placeholder, "*")
    end

    def default_persister
      @default_persister ||= begin
        default_persister = VCR.configuration.default_cassette_options[:persist_with]
        VCR.configuration.cassette_persisters[default_persister]
      end
    end

    def default_or_option(type, option_name, cassette_use)
      cassette_use[type] || VCR.configuration.default_cassette_options[option_name]
    end

    def path_for_cassette_use(cassette_use)
      persister_name = default_or_option(:persister, :persist_with, cassette_use)
      persister = VCR.configuration.cassette_persisters[persister_name]

      serializer_name = default_or_option(:serializer, :serialize_with, cassette_use)
      serializer = VCR.cassette_serializers[serializer_name]
      cassette_storage_key = "#{cassette_use[:pattern]}.#{serializer.file_extension}"
      cassette_path_with_wildcard(cassette_storage_key, persister)
    end

    def all_vcr_persisters
      # dirty, but VCR::Cassette::Persisters does not expose the persisters
      VCR.cassette_persisters.instance_variable_get(:@persisters)
    end
  end
end
