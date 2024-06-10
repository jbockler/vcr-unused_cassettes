# frozen_string_literal: true

require_relative "unused_cassettes/version"

module VCR
  module UnusedCassettes
    require "vcr-unused_cassettes/railtie" if defined?(Rails)

    class Error < StandardError; end
  end
end
