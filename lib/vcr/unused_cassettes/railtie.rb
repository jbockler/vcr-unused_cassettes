require "vcr/unused_cassettes"

module VCR
  module UnusedCassettes
    if defined?(::Rails)
      class Railtie < Rails::Railtie
        railtie_name :vcr_unused_cassettes

        rake_tasks do
          path = File.expand_path(__dir__)
          Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
        end
      end
    else
      # satisfy zeitwerk loading even when rails is not present
      class Railtie
      end
    end
  end
end
