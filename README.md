# EasyLogging

#### Ruby utility that lets you include logging in your classes easily, without redundancy.

| Branch | Status |
| ------ | ------ |
| Release | [![Build Status](https://travis-ci.org/thisismydesign/easy_logging.svg?branch=release)](https://travis-ci.org/thisismydesign/easy_logging)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/easy_logging/badge.svg?branch=release)](https://coveralls.io/github/thisismydesign/easy_logging?branch=release)   [![Gem Version](https://badge.fury.io/rb/easy_logging.svg)](https://badge.fury.io/rb/easy_logging)   [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/easy_logging?type=total)](https://rubygems.org/gems/easy_logging) |
| Development | [![Build Status](https://travis-ci.org/thisismydesign/easy_logging.svg?branch=master)](https://travis-ci.org/thisismydesign/easy_logging)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/easy_logging/badge.svg?branch=master)](https://coveralls.io/github/thisismydesign/easy_logging?branch=master) |

## Features

- Adds logging functionality to any class with one, short, self-descriptive command
- Logger works in both class and instance methods
- Logger is specific to class and contains class name

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_logging'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_logging

## Usage

Add `include EasyLogging` to any class you want to extend with logging functionality.

```ruby
require 'easy_logging'

class YourClass
  include EasyLogging

  def do_something
    # ...
    logger.info 'something happened'
  end
end

class YourOtherClass
  include EasyLogging

  def self.do_something
    # ...
    logger.info 'something happened'
  end
end

YourClass.new.do_something
YourOtherClass.do_something
```

Output:
```
I, [2017-06-03T21:59:25.160686 #5900]  INFO -- YourClass: something happened
I, [2017-06-03T21:59:25.160686 #5900]  INFO -- YourOtherClass: something happened
```

## Feedback

Any feedback is much appreciated.

I can only tailor this project to fit use-cases I know about - which are usually my own ones. If you find that this might be the right direction to solve your problem too but you find that it's suboptimal or lacks features don't hesitate to contact me.

Please let me know if you make use of this project so that I can prioritize further efforts.

## Development

This gem is developed using Bundler conventions. A good overview can be found [here](http://bundler.io/v1.14/guides/creating_gem.html).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thisismydesign/easy_logging.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
