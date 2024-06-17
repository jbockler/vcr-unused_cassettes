# frozen_string_literal: true

require_relative "lib/vcr/unused_cassettes/version"

Gem::Specification.new do |spec|
  spec.name = "vcr-unused_cassettes"
  spec.version = VCR::UnusedCassettes::VERSION
  spec.authors = ["Josch Bockler"]
  spec.email = ["9265647+jbockler@users.noreply.github.com "]

  spec.summary = "Find your unused VCR cassettes"
  spec.description = "Adds a rake task to find unused VCR cassettes in your project. To check for them in your CI or if you just want to cleanup."
  spec.homepage = "https://github.com/jbockler/vcr-unused_cassettes"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.metadata["source_code_uri"]}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "vcr"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
