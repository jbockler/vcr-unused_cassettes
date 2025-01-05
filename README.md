# Vcr::UnusedCassettes

This gem provides a way to detect unused [VCR](https://github.com/vcr/vcr) cassettes. It is intended to be used in a test suite to ensure that all VCR cassettes are being used. You could run this in your CI pipeline to ensure that no cassettes are being left behind.


## Pre-requisites

This gem currently only is supposed to work with minitest, but rspec and cucumber support is planned.

The interpretation of which cassettes are being used is pretty simple in the moment. Only string literals and some basic use of local variables is interpreted at the moment. If you do some more magic with the `VCR.use_cassette` calls, it is possible that you get false positives. 

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add vcr-unused_cassettes --group "development, test"

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install vcr-unused_cassettes

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
- add automated tests
- track constants that are used in the `VCR.use_cassette` calls
- find usages of cassettes when test name is used
- Add support for multiple cassette persisters in the same project
- Add support for rspec and cucumber
- create multiple run configurations to use e.g. minitest and cucumber in the same repo

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jbockler/vcr-unused_cassettes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jbockler/vcr-unused_cassettes/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Vcr::UnusedCassettes project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jbockler/vcr-unused_cassettes/blob/master/CODE_OF_CONDUCT.md).
