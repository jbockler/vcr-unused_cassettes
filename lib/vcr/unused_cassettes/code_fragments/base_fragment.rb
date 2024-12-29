# frozen_string_literal: true

module VCR::UnusedCassettes
  module CodeFragments
    class BaseFragment
      attr_reader :content, :file, :line_number

      delegate :include?, to: :content

      def initialize(file, line_number, content)
        @file = file
        @line_number = line_number
        @content = content
      end

      def strip_comments!
        comment_start_index = @content.index(/#[^\{]/)
        @content = @content[0..comment_start_index] if comment_start_index
      end
    end
  end
end
