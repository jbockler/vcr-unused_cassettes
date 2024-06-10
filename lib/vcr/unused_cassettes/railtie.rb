require "vcr/unused_cassettes"
require "rails"

module VCR
  module UnusedCassettes
    class Railtie < Rails::Railtie
      railtie_name :vcr_unused_cassettes

      rake_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end
    end
  end
end
