# frozen_string_literal: true

require "prism"

module VCR::UnusedCassettes
  class CassetteUsageFinder
    attr_accessor :filename, :used_cassettes

    def initialize(filename)
      self.filename = filename
      self.used_cassettes = []
    end

    def find_cassette_usages
      parse_result = Prism.parse_file(filename)
      return [] unless parse_result

      find_cassette_usages_in(parse_result.value)

      used_cassettes
    end

    def find_cassette_usages_in(node)
      return if node.nil?

      if node_contains_call?(node)
        found_name = find_cassette_name(node)
        unless found_name.nil?
          used_cassettes << found_name if found_name =~ /[a-zA-Z0-9]/
        end
      end

      return if node.child_nodes.nil?

      node.child_nodes.each do |child_node|
        find_cassette_usages_in(child_node)
      end
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
      cassette_name = nil
      case cassette_argument
      when Prism::InterpolatedStringNode
        cassette_name = cassette_argument.parts.map do |part_node|
          case part_node
          when Prism::StringNode
            part_node.unescaped
          when Prism::EmbeddedStatementsNode
            "*"
          else
            raise "dont know how to handle #{part_node.class}"
          end
        end.join
      when Prism::StringNode
        # just a string literal
        cassette_name = cassette_argument.unescaped
      else
        raise "dont know how to handle #{cassette_argument.class}"
      end
      cassette_name
    end
  end
end