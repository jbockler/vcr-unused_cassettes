# Vcr::UnusedCassettes

This gem provides a way to detect unused [VCR](https://github.com/vcr/vcr) cassettes. It is intended to be used in a test suite to ensure that all VCR cassettes are being used. You could run this in your CI pipeline to ensure that no cassettes are being left behind.


## Pre-requisites

This gem currently only is supposed to work with minitest, but rspec and cucumber support is planned.

The interpretation of which cassettes are being used is pretty simple at the moment. Only string literals and some basic use of variables and constants is interpreted at the moment. If you do some more magic with the `VCR.use_cassette` calls, it is possible that you get false positives. If you encounter such a case, please open a pr or an issue with a code example.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add vcr-unused_cassettes --group "development, test"

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install vcr-unused_cassettes

This gem require the VCR gem to be installed and configured in the same environment too. 

Additionally you have to load the rake tasks in your application. Add the following line to your `Rakefile`:

```ruby
require "vcr-unused_cassettes"

spec = Gem::Specification.find_by_name
rakefile = "#{spec.gem_dir}/lib/vcr/unused_cassettes/Rakefile"
load rakefile
```

If you are using Rails you don't have to do that. This gem ships with a Railtie that automatically loads the rake tasks.

## Usage

This gem provides 2 tasks:

### Check for unused cassettes
    $ rails vcr:unused_cassettes:check

### Remove unused cassettes
    $ rails vcr:unused_cassettes:remove

## Roadmap
Open for contributions. Some ideas what could be done in the future:
- automate manual tests into rspec tests
- find usages of cassettes when test name is used
- Add support for rspec and cucumber
- create multiple run configurations to use e.g. minitest and cucumber in the same repo
- fancy spinner with progress indicator (configurable for ci environments)
- parallelize the analysis of the cassettes

## Contributing

Contributions and ideas are welcome. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more information.


## Code of Conduct

Everyone interacting in the Vcr::UnusedCassettes project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jbockler/vcr-unused_cassettes/blob/master/CODE_OF_CONDUCT.md).
