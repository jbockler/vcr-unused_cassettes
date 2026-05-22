# frozen_string_literal: true

require "prism"

module VCR::UnusedCassettes
  class CassetteUsageFinder
    attr_accessor :filename, :used_cassettes, :warnings, :call_context

    def initialize(filename)
      self.filename = filename
      self.used_cassettes = []
      self.warnings = []
    end

    def find_cassette_usages
      parse_result = Prism.parse_file(filename)
      return [[], []] unless parse_result

      method_index = MethodIndex.new(parse_result.value)
      self.call_context = CallContext.new(method_index: method_index)

      find_cassette_usages_in(parse_result.value)

      [used_cassettes, warnings]
    end

    def find_cassette_usages_in(node)
      return if node.nil?

      call_context.track(node)

      if node_contains_call?(node)
        record_cassette_uses(node)
      end

      return if node.child_nodes.nil?

      if node.is_a?(Prism::DefNode)
        call_context.enter_method(node)
        begin
          node.child_nodes.each { |child| find_cassette_usages_in(child) }
        ensure
          call_context.exit_method
        end
      else
        node.child_nodes.each { |child| find_cassette_usages_in(child) }
      end
    end

    def record_cassette_uses(node)
      found_name = find_cassette_name(node)
      return if found_name.nil?

      cassette_options = extract_options(node)
      patterns = found_name.is_a?(CallContext::MultiValue) ? found_name.values : [found_name]

      patterns.each do |pattern|
        next unless pattern.is_a?(String) && /[a-zA-Z0-9*]/.match?(pattern)
        cassette_use = {pattern: pattern}
        cassette_use[:persister] = cassette_options[:persist_with] if cassette_options&.has_key?(:persist_with)
        cassette_use[:serializer] = cassette_options[:serialize_with] if cassette_options&.has_key?(:serialize_with)
        used_cassettes << cassette_use
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
        warning.message = "Could not determine cassette name for #{filename}:#{node.location.start_line}"
        warning.details = error.message
        warning.backtrace = error.backtrace
      end
    end
  end
end
