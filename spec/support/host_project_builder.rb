# frozen_string_literal: true

require "tmpdir"
require "fileutils"

module HostProjectBuilder
  class Project
    attr_reader :root

    def initialize(root)
      @root = root
      FileUtils.mkdir_p(File.join(root, "test"))
      FileUtils.mkdir_p(File.join(root, "test/vcr_cassettes"))
    end

    def add_test(filename, body)
      File.write(File.join(root, "test", filename), body)
    end

    def add_spec(filename, body)
      FileUtils.mkdir_p(File.join(root, "spec"))
      File.write(File.join(root, "spec", filename), body)
    end

    def add_cassette(filename, body = "---\nhttp_interactions: []\n")
      File.write(File.join(root, "test/vcr_cassettes", filename), body)
    end
  end

  # NOT parallel-safe: mutates Dir.chdir and VCR.configuration.cassette_library_dir,
  # both of which are process-wide. Don't reach for `rspec --parallel` without
  # rethinking this helper.
  def with_host_project
    Dir.mktmpdir("vcr-unused-host-") do |dir|
      project = Project.new(dir)
      previous_dir = VCR.configuration.cassette_library_dir
      VCR.configure { |c| c.cassette_library_dir = File.join(dir, "test/vcr_cassettes") }
      begin
        Dir.chdir(dir) { yield project }
      ensure
        VCR.configure { |c| c.cassette_library_dir = previous_dir }
      end
    end
  end
end

RSpec.configure do |config|
  config.include HostProjectBuilder
end
