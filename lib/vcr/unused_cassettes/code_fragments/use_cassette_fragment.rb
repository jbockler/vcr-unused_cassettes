# frozen_string_literal: true

module VCR::UnusedCassettes
  module CodeFragments
    class UseCassetteFragment < BaseFragment
      SNIPPET = "VCR.use_cassette"

      def find_cassette_name
        possible_name = content[(content.index(SNIPPET) + SNIPPET.size)..]
        possible_name = possible_name[1..] if possible_name.starts_with?("(")
        possible_name.strip!

        # interpret string interpolation as wildcard
        possible_name.gsub!(/\#\{[^\}]*\}/, "*")

        start_char = possible_name[0]
        return if %W[" '].include?(start_char) # currently only plain strings are supported

        end_of_string = possible_name.index(/[^\\]#{start_char}/, 1)
        name = possible_name[1..end_of_string]
        # cassette name only contains wildcards and/or whitespace
        return if (name.chars.uniq - ["*", "_", " "]).empty?

        name
      end

      def snippet_present?
        content.include?(SNIPPET)
      end
    end
  end
end
