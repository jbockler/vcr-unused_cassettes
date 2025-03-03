# frozen_string_literal: true

require "zeitwerk"

module VCR
  module UnusedCassettes
    @loader = Zeitwerk::Loader.for_gem_extension(VCR)
    @loader.setup

    require_relative "unused_cassettes/railtie" if defined?(Rails)

    class Error < StandardError; end

    def self.eager_load!
      @loader.eager_load
    end
  end
end
