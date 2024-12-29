# frozen_string_literal: true

module VCR::UnusedCassettes
  module CodeFragments
    class UseCassetteFragment < BaseFragment
      SNIPPET = "VCR.use_cassette"

      attr_accessor :calling_node

      def find_cassette_name
        possible_name = content[(content.index(SNIPPET) + SNIPPET.size)..].strip
        possible_name = possible_name[1..] if possible_name.starts_with?("(")
        possible_name.strip!

        # interpret string interpolation as wildcard
        possible_name.gsub!(/\#\{[^\}]*\}/, "*")

        start_char = possible_name[0]
        return unless %W[" '].include?(start_char) # currently only plain strings are supported

        end_of_string = possible_name.index(/[^\\]#{start_char}/, 1)
        name = possible_name[1..end_of_string]
        # cassette name only contains wildcards and/or whitespace
        return if (name.chars.uniq - ["*", "_", " "]).empty?

        name
      end

      def snippet_present?
        content.include?(SNIPPET)
      end

      def snipped_called?
        find_calling_node
        !calling_node.nil?
      end

      def find_calling_node
        require "prism" # should not raise an error, as contained standardlib and required ruby version set

        parse_result = Prism.parse(content)
        return unless parse_result

        find_calling_node_in(parse_result.value)
      end

      def find_calling_node_in(node)
        if node_contains_call?(node)
          self.calling_node = node
          return true
        end

        return false if node.child_nodes.nil?

        # Recursively check all child nodes
        node.child_nodes.compact.any? do |child|
          find_calling_node_in(child)
        end
      end

      def node_contains_call?(node)
        return unless node.is_a?(Prism::CallNode)

        receiver = node.receiver
        return false unless receiver.is_a?(Prism::ConstantReadNode) && receiver.name == :VCR

        node.name == :use_cassette
      end
    end
  end
end
