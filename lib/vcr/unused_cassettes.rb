# frozen_string_literal: true

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem_extension(VCR)
loader.setup

module VCR
  module UnusedCassettes
    require_relative "unused_cassettes/railtie" if defined?(Rails)

    class Error < StandardError; end
  end
end
