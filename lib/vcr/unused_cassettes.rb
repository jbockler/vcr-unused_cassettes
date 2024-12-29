# frozen_string_literal: true

require_relative "unused_cassettes/version"
require_relative "unused_cassettes/runner"
require_relative "unused_cassettes/cassette_usage_finder"
require_relative "unused_cassettes/warning"

module VCR
  module UnusedCassettes
    require_relative "unused_cassettes/railtie" if defined?(Rails)

    class Error < StandardError; end
  end
end
