# frozen_string_literal: true

require_relative "unused_cassettes/version"
require_relative "unused_cassettes/runner"
require_relative "unused_cassettes/ast_runner"
require_relative "unused_cassettes/cassette_usage_finder"
require_relative "unused_cassettes/code_fragments/base_fragment"
require_relative "unused_cassettes/code_fragments/use_cassette_fragment"

module VCR
  module UnusedCassettes
    require_relative "unused_cassettes/railtie" if defined?(Rails)

    class Error < StandardError; end
  end
end
