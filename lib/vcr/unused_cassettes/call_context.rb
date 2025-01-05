# frozen_string_literal: true

module VCR::UnusedCassettes
  class CallContext
    ValueUnresolveable = Class.new(StandardError)

    def initialize
      @context = {
        variables: {},
        constants: {}
      }
    end

    def track(node)
      reset_local_variables! if new_test_node?(node)
      case node.type
      when :local_variable_write_node
        store_variable(node.name, node.value)
      when :constant_write_node
        store_constant(node.name, node.value)
      when :instance_variable_write_node
        store_variable(node.name, node.value)
      end
    end

    def resolve_variable(variable_name)
      @context.dig(:variables, variable_name)
    end

    def resolve_constant(constant_name)
      @context.dig(:constants, constant_name)
    end

    def extract_value(node, string_interpolation_error: :raise)
      case node.type
      when :nil_node
        nil
      when :string_node, :symbol_node
        node.unescaped
      when :hash_node
        node.elements.each_with_object({}) do |element, hash|
          key = extract_value(element.key, string_interpolation_error: string_interpolation_error)
          value = extract_value(element.value, string_interpolation_error: string_interpolation_error)
          hash[key] = value
        rescue ValueUnresolveable
          next
        end
      when :interpolated_string_node
        node.parts.map do |part_node|
          if part_node.type == :embedded_statements_node
            if part_node.statements.body.size != 1
              if string_interpolation_error == :raise
                raise ValueUnresolveable, "Could not resolve value for node: #{part_node.inspect}"
              elsif string_interpolation_error == :wildcard
                "*"
              end
            else
              extract_value(part_node.statements.body.first, string_interpolation_error: string_interpolation_error)
            end
          else
            extract_value(part_node, string_interpolation_error: string_interpolation_error)
          end
        rescue ValueUnresolveable
          if string_interpolation_error == :raise
            raise ValueUnresolveable, "Could not resolve value for node: #{part_node.inspect}"
          elsif string_interpolation_error == :wildcard
            "*"
          end
        end.join
      when :local_variable_read_node, :instance_variable_read_node
        resolve_variable(node.name)
      when :constant_read_node
        @context.dig(:constants, node.name)
      else
        if node.respond_to?(:value) && !node.value.is_a?(Prism::Node)
          node.value
        else
          raise ValueUnresolveable, "Could not resolve value for node: #{node.inspect}"
        end
      end
    end

    private

    def reset_local_variables!
      @context[:variables].select! { |key, _value| key.start_with?("@") }
    end

    def store_variable(name, value_node)
      @context[:variables][name] = extract_value(value_node)
    rescue ValueUnresolveable
      # todo add debug logging
    end

    def store_constant(name, value_node)
      @context[:constants][name] = extract_value(value_node)
    rescue ValueUnresolveable
      # todo add debug logging
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
