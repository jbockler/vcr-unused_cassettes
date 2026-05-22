# frozen_string_literal: true

module VCR::UnusedCassettes
  class CallContext
    ValueUnresolveable = Class.new(StandardError)

    # Reads under :raise mode raise ValueUnresolveable; only :wildcard callers
    # can safely unpack the values.
    MultiValue = Struct.new(:values)

    def initialize(method_index: nil)
      @method_index = method_index
      @context = {
        variables: {},
        constants: {}
      }
      @parameter_scopes = []
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

    def enter_method(def_node)
      @parameter_scopes.push(build_parameter_frame(def_node))
    end

    def exit_method
      @parameter_scopes.pop
    end

    def resolve_variable(variable_name)
      @parameter_scopes.reverse_each do |frame|
        return frame[variable_name] if frame.key?(variable_name)
      end
      @context.dig(:variables, variable_name)
    end

    def resolve_constant(constant_name)
      @context.dig(:constants, constant_name)
    end

    def extract_value(node, string_interpolation_error: :raise)
      case node.type
      when :nil_node
        nil
      when :string_node
        node.unescaped
      when :symbol_node
        node.unescaped.to_sym
      when :hash_node, :keyword_hash_node
        node.elements.each_with_object({}) do |element, hash|
          if element.type == :assoc_splat_node
            hash.merge(extract_value(element.value, string_interpolation_error: string_interpolation_error))
            next
          end
          key = extract_value(element.key, string_interpolation_error: string_interpolation_error)
          value = extract_value(element.value, string_interpolation_error: string_interpolation_error)
          hash[key] = value
        rescue ValueUnresolveable
          next
        end
      when :array_node
        node.elements.map do |element|
          extract_value(element, string_interpolation_error: string_interpolation_error)
        end
      when :interpolated_string_node
        part_options = node.parts.map { |part_node| interpolation_part_options(part_node, string_interpolation_error) }
        combinations = part_options.reduce([[]]) do |acc, options|
          acc.flat_map { |prefix| options.map { |opt| prefix + [opt] } }
        end
        results = combinations.map { |parts| parts.map(&:to_s).join }.uniq
        (results.size == 1) ? results.first : MultiValue.new(results)
      when :local_variable_read_node, :instance_variable_read_node
        unless variable_bound?(node.name)
          raise ValueUnresolveable, "Could not resolve value for node: #{node.inspect}"
        end
        value = resolve_variable(node.name)
        if value.is_a?(MultiValue) && string_interpolation_error != :wildcard
          raise ValueUnresolveable, "Multi-value binding cannot be embedded: #{node.inspect}"
        end
        value
      when :constant_read_node
        @context.dig(:constants, node.name)
      when :assoc_splat_node
        extract_value(node.value, string_interpolation_error: string_interpolation_error)
      else
        if node.respond_to?(:value) && !node.value.is_a?(Prism::Node)
          node.value
        else
          raise ValueUnresolveable, "Could not resolve value for node: #{node.inspect}"
        end
      end
    end

    private

    def variable_bound?(name)
      return true if @parameter_scopes.any? { |frame| frame.key?(name) }
      @context[:variables].key?(name)
    end

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

    def build_parameter_frame(def_node)
      frame = {}
      return frame if def_node.parameters.nil?
      params = def_node.parameters

      call_bindings = @method_index ? @method_index.call_arguments_for(def_node.name) : []

      parameter_specs(params).each do |name, default_node|
        candidates = []
        if default_node
          begin
            candidates << extract_value(default_node, string_interpolation_error: :raise)
          rescue ValueUnresolveable
          end
        end
        call_bindings.each do |call_binding|
          candidates << call_binding[name] if call_binding.key?(name)
        end
        candidates = flatten_candidates(candidates)
        next if candidates.empty?
        frame[name] = (candidates.size == 1) ? candidates.first : MultiValue.new(candidates)
      end

      frame
    end

    def parameter_specs(parameters_node)
      specs = []
      if parameters_node.respond_to?(:requireds)
        parameters_node.requireds.each { |p| specs << [p.name, nil] if p.respond_to?(:name) }
      end
      if parameters_node.respond_to?(:optionals)
        parameters_node.optionals.each { |p| specs << [p.name, p.value] }
      end
      if parameters_node.respond_to?(:keywords)
        parameters_node.keywords.each do |p|
          default = p.respond_to?(:value) ? p.value : nil
          specs << [p.name, default]
        end
      end
      specs
    end

    def interpolation_part_options(part_node, string_interpolation_error)
      if part_node.type == :embedded_statements_node
        if part_node.statements.body.size != 1
          raise ValueUnresolveable, "Could not resolve value for node: #{part_node.inspect}"
        end
        value = extract_value(part_node.statements.body.first, string_interpolation_error: string_interpolation_error)
        value.is_a?(MultiValue) ? value.values : [value]
      else
        [extract_value(part_node, string_interpolation_error: string_interpolation_error)]
      end
    rescue ValueUnresolveable
      raise if string_interpolation_error == :raise
      ["*"]
    end

    def flatten_candidates(candidates)
      flat = []
      candidates.each do |c|
        if c.is_a?(MultiValue)
          flat.concat(c.values)
        else
          flat << c
        end
      end
      flat.uniq
    end
  end
end
