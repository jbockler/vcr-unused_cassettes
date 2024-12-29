# frozen_string_literal: true

module VCR::UnusedCassettes
  class Warning
    attr_accessor :message, :details, :backtrace

    def self.print(warnings)
      return if warnings.nil? || warnings.empty?

      puts "Warnings:"
      warnings.each do |warning|
        puts warning.message
      end
    end
  end
end
