# ReformErrorsObjects

If you need errors objects instead of dotted errors using trailblazer/reform gem you came to right place.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reform_errors_objects'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reform_errors_objects

## Usage

For instance you have some declared form with nested objects/collections and so on...
You got request with invalid data.
And you need to return the same way structured error messages, let's say, in json response.

### so your form looks like:
```ruby
require 'dry-validation'
require 'reform/form/dry'
require 'reform'

class DevicesForm < Reform::Form
  feature Reform::Form::Dry

  property :id

  collection :devices, default: [], populate_if_empty: OpenStruct do

    property :imei

    validation do
      required(:imei).filled
    end
  end
end

form = DevicesForm.new(OpenStruct.new)
```

### incomming hash is:
```ruby
incomming_hash = { id: 22, devices: [{ imei: 21 }, { imei: nil }] }
```

### you do validation:
```ruby
form.validate(incomming_hash)
```

### then you can call #objects method on errors instance
```ruby
# reform validation errors format
form.errors.objects
```

### and it returns stuctured nested errors according you form schema
```ruby
{:devices=>{1=>{:imei=>["must be filled"]}}}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/reform_errors_objects. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ReformErrorsObjects project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/reform_errors_objects/blob/master/CODE_OF_CONDUCT.md).
