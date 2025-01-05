# frozen_string_literal: true

module VCR::UnusedCassettes
  class CallContext
    def initialize
      reset_context!
    end

    def track(node)
      reset_context! if new_test_node?(node)
      case node.type
      when :local_variable_write_node
        store_variable(node.name, node.value)
      end
    end

    def resolve_variable_call(variable_name)
      @context[variable_name]
    end

    private

    def reset_context!
      @context = {}
    end

    def store_variable(name, value_node)
      value = if value_node.type == :string_node
        value_node.unescaped
      elsif value_node.respond_to?(:value) && !value_node.value.is_a?(Prism::Node)
        value_node.value
      end
      return unless value
      @context[name] = value
    end

    def new_test_node?(node)
      case node.type
      when :def_node
        if node.name.start_with?("test")
          return true
        end
      when :call_node
        if node.name == :test
          return true
        end
      end
      false
    end
  end
end
