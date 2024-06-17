# Vcr::UnusedCassettes

This gem provides a way to detect unused [VCR](https://github.com/vcr/vcr) cassettes. It is intended to be used in a test suite to ensure that all VCR cassettes are being used. You could run this in your CI pipeline to ensure that no cassettes are being left behind.

Be aware that the recognition of the cassettes that are in use is really basic. If you do some more complex stuff this Gem might not be able to detect all cassettes that are in use.

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

It is enough to run the following command to detect unused cassettes:

    $ rails vcr:unused_cassettes

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jbockler/vcr-unused_cassettes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jbockler/vcr-unused_cassettes/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Vcr::UnusedCassettes project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jbockler/vcr-unused_cassettes/blob/master/CODE_OF_CONDUCT.md).
