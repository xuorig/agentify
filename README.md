# Agentify

> Agent Thread as a Service

Agentify allows you to delegate expensive I/O operations to an agent thread instead of making calls inline. See Usage for examples.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'agentify'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install agentify

## Usage

Agentify provides you with abstractions on which you can build. The two important ones are `Agentify::Agent` and `Agentify::Bucket`.

`Agentify::Agent` is the actual Agent. Using an agent you can set timers, listen for certain events, and trigger these events:

```ruby
my_agent = Agentify::Agent.new

# use timers to execute a block every x amount of time
my_agent.every(1.second) do |my_arg|
  make_a_long_http_call(my_arg)
end

# listen to certain events
my_agent.on(:new_data) { get_new_data }


# start the agent thread
my_agent.start

# trigger events
update_data(new_data)
my_agent.trigger(:new_data)
```

For instrumentation purposes you can use `Agentify::Bucket`, a thread safe queue-like object:

Defining your own bucket:

```ruby

class RequestTimeBucket < Agentify::Bucket
  def add_request_time_data(data)
    # Agentify::Bucket defines the add method, a thread safe method to add data to the bucket
    add({ start: data[:start], end: data[:end] })
  end
end

REQUEST_TIME_BUCKET = RequestTimeBucket.new(max_size: 100)

REQUEST_TIME_BUCKET.add_request_time_data({ start: start_time, end: end_time })

data_to_be_sent = REQUEST_TIME_BUCKET.consume!
```

Using them together:

```ruby
my_agent.every(1.second) do
  send_data_to_my_server(REQUEST_TIME_BUCKET.consume!)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xuorig/agentify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

