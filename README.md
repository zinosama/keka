# Keka

Keka (Japanese for 'result') is a wrapper that represents the result of a particular execution, along with any message returned.

## Installation

```ruby
gem 'keka'
```

## Usage

Below is an example of how the various methods can come together.

```ruby
class Order
  def refund(cancel_delivery = true)
    Keka.run do
      # returns an err keka with provided msg if !refundable?
      Keka.err_unless!(refundable?, 'Payment is no longer refundable.')
      # returns an err keka with provided msg if !refund!
      Keka.err_unless!(payment.refund, 'Refund failed. Please try again')
      # execute statements if nothing 'return' from above
      do_something_else
      # if cancel_delivery
      # => returns an err keka with provided msg if !remove_delivery_assignment
      Keka.err_unless!(remove_delivery_assignment, 'Refunded but failed to remove delivery.') if cancel_delivery
      # returns an ok keka if nothing 'return' from above
    end
  end

  private

  def remove_delivery_assignment
    Keka.run do
      # returns an ok keka if already_removed?
      Keka.ok_if! already_removed?
      # returns an err keka with no msg if !remove!
      Keka.err_unless! remove!
      # returns an ok keka if nothing 'return' from above
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

Of course, you can also use `.err_unless!`, `.err_if!`, and `.ok_if!` outside
of the `Keka.run` block.

### Abort Unconditionally

Sometimes you know you want to abort, but you also need to a few things before aborting, such as saving the error result to database, logging, or submitting a metric to your monitoring service. You can use `.err!` or `.ok!` methods to abort from the current `Keka.run` block. Both methods can be invoked with or without a message argument.

```ruby
def refund
  Keka.run do
    processor_response = payment.refund
    unless processor_response.success
      payment.log_processor_errors(processor_response.errors)
      Keka.err! processor_response.errors
    end
  end
end
```

### Handle Exceptions

Before version 0.2.0, handling exceptions in `.run` block is a bit tricky. You might do something like this

```ruby
def validate_purchase(item_ids)
  Keka.run do
    Item.find(item_ids)
  rescue ActiveRecord::RecordNotFound
    Keka.err_if! true, 'Some item is unavailable'
  end
end
```

After version 0.2.0, you can simply
```ruby
# * Returns ok result if no exception is raised.
# * Returns err result if ActiveRecord::RecordNotFound is raised, with msg set
#   to 'Some item is unavailable'.
# * Raises if any other non-keka exception is thrown.
def validate_purchase(item_ids)
  Keka.rescue_with(ActiveRecord::RecordNotFound, 'Some item is unavailable')
    .run { Item.find(item_ids) }
end
```

You can also chain `.rescue_with`
```ruby
def validate_purchase(store_id, new_item_payload)
  Keka.rescue_with(ActiveRecord::RecordNotFound, 'Some item is unavailable')
    .rescue_with(ActiveRecord::RecordInvalid, 'Invalid payload')
    .run do
      store = Store.find(store_id)
      store.items.create!(new_item_payload)
    end
end
```

Note, by design, `.rescue_with` only rescues from descendants of StandardError. This will **NOT** work.
```ruby
def invalid_example
  # The .rescue_with does NOTHING here. This method will raise a NoMemoryError exception.
  Keka.rescue_with(NoMemoryError, 'oops')
    .run { raise NoMemoryError.new }
end
```

### ActiveRecord (ActiveModel) support

One of the most common boundary conditions is validation.

```ruby
class User
  validates :name, :city, presence: true
end

if User.new(name: nil, city: nil).valid?
  # do something
else
  # return errors
end
```

Keka supports `ActiveModel::Errors` as `msg` argument to return full message and errors per fields

```ruby
user = User.new(name: nil, city: nil)

result = Keka.run do
  Keka.err_unless! user.valid?, user.errors
end

puts result.ok?
# => false

puts result.msg
# => "Name can't be blank, City can't be blank"

puts result.errors
# => {name: ["can't be blank"], city: ["can't be blank"]}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zinosama/keka.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
