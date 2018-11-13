# Keka

Keka (Japanese for 'result') is a wrapper that represents the result of a particular execution, along with any message returned.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'keka'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keka

## Usage

Below is an example of how the various methods can come together.

```ruby
class Order
  def refund
    Keka.run do
      Keka.err_unless!(refundable?, 'Payment is no longer refundable.')
      Keka.err_unless!(refund!, 'Refund failed. Please try again')
      do_something_else
      Keka.err_unless!(remove_delivery, 'Refunded but failed to remove delivery.') if cancel_delivery?
    end
  end

  private

  def remove_delivery
    Keka.run do
      Keka.ok_if! already_removed?
      Keka.err_unless! remove!
    end
  end
end

class SomeController
  def some_action
    keka = @order.refund
    if keka.ok?
      head :ok
    else
      render json: { error: keka.msg }, status: 422
    end
  end
end
```

Of course, you can also use `.err_unless!`, `err_if!`, and `ok_if!` outside
of the `Keka.run` context.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zinosama/keka.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
