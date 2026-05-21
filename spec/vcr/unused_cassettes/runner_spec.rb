# frozen_string_literal: true

require "spec_helper"

RSpec.describe VCR::UnusedCassettes::Runner do
  describe "#find_unused_cassettes" do
    it "reports cassettes that no test references" do
      with_host_project do |project|
        project.add_test "foo_test.rb", <<~RUBY
          class FooTest < Minitest::Test
            test "a" do
              VCR.use_cassette("used") { }
            end
          end
        RUBY
        project.add_cassette "used.yml"
        project.add_cassette "unused.yml"

        unused, warnings = described_class.new.find_unused_cassettes

        expect(unused.map { |path| File.basename(path) }).to match_array(["unused.yml"])
        expect(warnings).to be_empty
      end
    end

    it "reports no unused cassettes when every cassette is referenced" do
      with_host_project do |project|
        project.add_test "foo_test.rb", <<~RUBY
          class FooTest < Minitest::Test
            test "a" do
              VCR.use_cassette("a") { }
            end
            test "b" do
              VCR.use_cassette("b") { }
            end
          end
        RUBY
        project.add_cassette "a.yml"
        project.add_cassette "b.yml"

        unused, warnings = described_class.new.find_unused_cassettes

        expect(unused).to be_empty
        expect(warnings).to be_empty
      end
    end

    it "matches wildcard cassette patterns against existing files" do
      with_host_project do |project|
        project.add_test "foo_test.rb", <<~RUBY
          class FooTest < Minitest::Test
            test "wildcard" do
              VCR.use_cassette("user_\#{some_call}") { }
            end
          end
        RUBY
        project.add_cassette "user_1.yml"
        project.add_cassette "user_2.yml"
        project.add_cassette "admin.yml"

        unused, warnings = described_class.new.find_unused_cassettes

        expect(unused.map { |path| File.basename(path) }).to match_array(["admin.yml"])
        expect(warnings).to be_empty
      end
    end
  end
end
