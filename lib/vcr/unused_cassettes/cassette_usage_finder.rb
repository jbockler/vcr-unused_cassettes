# frozen_string_literal: true

require "prism"

module VCR::UnusedCassettes
  class CassetteUsageFinder
    attr_accessor :filename, :used_cassettes, :warnings, :call_context

    def initialize(filename)
      self.filename = filename
      self.used_cassettes = []
      self.warnings = []
      self.call_context = CallContext.new
    end

    def find_cassette_usages
      parse_result = Prism.parse_file(filename)
      return [[], []] unless parse_result

      find_cassette_usages_in(parse_result.value)

      [used_cassettes, warnings]
    end

    def find_cassette_usages_in(node)
      return if node.nil?

      call_context.track(node)

      if node_contains_call?(node)
        found_name = find_cassette_name(node)
        if !found_name.nil? && /[a-zA-Z0-9]/.match?(found_name)
          cassette_use = {pattern: found_name}
          cassette_options = extract_options(node)
          cassette_use[:persister] = cassette_options[:persist_with] if cassette_options&.has_key?(:persist_with)
          cassette_use[:serializer] = cassette_options[:serialize_with] if cassette_options&.has_key?(:serialize_with)
          used_cassettes << cassette_use
        end
      end

      return if node.child_nodes.nil?

      node.child_nodes.each do |child_node|
        find_cassette_usages_in(child_node)
      end
    end

    def extract_options(node)
      return nil if node.arguments.arguments.size <= 1
      node.arguments.arguments.each do |argument_node|
        next unless argument_node.is_a?(Prism::KeywordHashNode)
        return call_context.extract_value(argument_node, string_interpolation_error: :raise)
      end
      nil
    rescue CallContext::ValueUnresolveable => error
      warnings << build_warning(node, error)
    end

    def node_contains_call?(node)
      return false unless node.is_a?(Prism::CallNode)

      receiver = node.receiver
      return false unless receiver.is_a?(Prism::ConstantReadNode) && receiver.name == :VCR

      node.name == :use_cassette
    end

    def find_cassette_name(node)
      # cassette is the first argument of the use_cassette call
      cassette_argument = node.arguments.arguments.first
      call_context.extract_value(cassette_argument, string_interpolation_error: :wildcard)
    rescue CallContext::ValueUnresolveable => error
      warnings << build_warning(node, error)
      nil
    end

    def build_warning(node, error)
      Warning.new.tap do |warning|
        warning.message = "Could not determine cassette name for #{filename}:#{node.line}"
        warning.details = error.message
        warning.backtrace = error.backtrace
      end
    end
  end
end
