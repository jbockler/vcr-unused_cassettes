# frozen_string_literal: true

require "prism"

module VCR::UnusedCassettes
  class MethodIndex
    def initialize(root_node)
      @definitions = {}
      @call_arguments = Hash.new { |h, k| h[k] = [] }
      collect_definitions(root_node)
      collect_calls(root_node, CallContext.new) unless @definitions.empty?
    end

    def call_arguments_for(method_name)
      @call_arguments[method_name] || []
    end

    private

    def collect_definitions(node)
      return if node.nil?
      @definitions[node.name] = node if node.is_a?(Prism::DefNode)
      return if node.child_nodes.nil?
      node.child_nodes.each { |child| collect_definitions(child) }
    end

    def collect_calls(node, context)
      return if node.nil?
      context.track(node)
      record_call(node, context) if known_helper_call?(node)
      return if node.child_nodes.nil?
      node.child_nodes.each { |child| collect_calls(child, context) }
    end

    def known_helper_call?(node)
      return false unless node.is_a?(Prism::CallNode)
      return false unless node.receiver.nil?
      @definitions.key?(node.name)
    end

    def record_call(call_node, context)
      def_node = @definitions[call_node.name]
      return if call_node.arguments.nil?

      positional_names = positional_parameter_names(def_node)
      keyword_names = keyword_parameter_names(def_node)
      call_binding = {}
      pos_index = 0
      positional_unknown = false

      call_node.arguments.arguments.each do |arg|
        case arg
        when Prism::KeywordHashNode
          arg.elements.each do |element|
            next unless element.is_a?(Prism::AssocNode)
            next unless element.key.is_a?(Prism::SymbolNode)
            name = element.key.unescaped.to_sym
            next unless keyword_names.include?(name)
            begin
              call_binding[name] = context.extract_value(element.value, string_interpolation_error: :raise)
            rescue CallContext::ValueUnresolveable
            end
          end
        when Prism::BlockArgumentNode
          # block arg does not consume a positional slot
        when Prism::SplatNode, Prism::ForwardingArgumentsNode
          # alignment between source args and parameter list is lost from here on
          positional_unknown = true
        else
          if !positional_unknown && pos_index < positional_names.size
            name = positional_names[pos_index]
            begin
              call_binding[name] = context.extract_value(arg, string_interpolation_error: :raise)
            rescue CallContext::ValueUnresolveable
            end
          end
          pos_index += 1
        end
      end

      @call_arguments[call_node.name] << call_binding unless call_binding.empty?
    end

    def positional_parameter_names(def_node)
      return [] if def_node.parameters.nil?
      params = def_node.parameters
      names = []
      names.concat(params.requireds.map(&:name)) if params.respond_to?(:requireds)
      names.concat(params.optionals.map(&:name)) if params.respond_to?(:optionals)
      names
    end

    def keyword_parameter_names(def_node)
      return [] if def_node.parameters.nil?
      params = def_node.parameters
      return [] unless params.respond_to?(:keywords)
      params.keywords.map(&:name)
    end
  end
end
