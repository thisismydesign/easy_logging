# EasyLogging

#### Ruby utility that lets you include a unique logger anywhere easily, without redundancy.

Inspired by [this StackOverflow thread](https://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes/44348303) `EasyLogging` provides an easy way to create and configure unique loggers for any [context](https://ruby-doc.org/stdlib/libdoc/rdoc/rdoc/RDoc/Context.html) as an alternative to having a global logger (e.g. `Rails.logger`). It uses the [native Ruby Logger from stdlib](http://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html) and has [no runtime dependencies](easy_logging.gemspec).

Status and support

- &#x2714; stable
- &#x2714; supported
- &#x2716; no ongoing development

<!--- Version informartion -->
*You are viewing the README of version [v0.4.0](/../../releases/tag/v0.4.0). You can find other releases [here](/../../releases).*
<!--- Version informartion end -->

| Branch | Status |
| ------ | ------ |
| Release | [![Build Status](https://travis-ci.org/thisismydesign/easy_logging.svg?branch=release)](https://travis-ci.org/thisismydesign/easy_logging)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/easy_logging/badge.svg?branch=release)](https://coveralls.io/github/thisismydesign/easy_logging?branch=release)   [![Gem Version](https://badge.fury.io/rb/easy_logging.svg)](https://badge.fury.io/rb/easy_logging)   [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/easy_logging?type=total)](https://rubygems.org/gems/easy_logging) |
| Development | [![Build Status](https://travis-ci.org/thisismydesign/easy_logging.svg?branch=master)](https://travis-ci.org/thisismydesign/easy_logging)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/easy_logging/badge.svg?branch=master)](https://coveralls.io/github/thisismydesign/easy_logging?branch=master)   [![Depfu](https://badges.depfu.com/badges/dd38e32dcfb6454086088482b945692a/count.svg)](https://depfu.com/github/thisismydesign/easy_logging) |

## Features

- Add logging functionality anywhere with one, short, descriptive command
- Logger is unique to context and contains relevant information (e.g. class name)
- Logger is pre-configurable globally (destination, level, formatter)
- Logger is fully configurable locally
- The same syntax works in any context (e.g. class or instance methods)

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

Add `include EasyLogging` to any context (e.g. a class) you want to extend with logging functionality.

```ruby
require 'easy_logging'

# Global pre-configuration for every Logger instance
EasyLogging.log_destination = 'app.log'
EasyLogging.level = Logger::DEBUG

class YourClass
  include EasyLogging

  def do_something
    logger.debug('foo')
  end
end

class YourOtherClass
  include EasyLogging

  def self.do_something
    # Local custom Logger configuration
    logger.formatter = proc do |severity, datetime, progname, msg|
      "#{severity}: #{msg}\n"
    end

    # ...

    logger.info('bar')
  end
end

YourClass.new.do_something
YourOtherClass.do_something
```

`app.log`:
```
D, [2018-03-13T13:35:40.337438 #44643] DEBUG -- YourClass: foo
INFO: bar
```

## Global configuration

**You should pre-configure EasyLogging before loading your application** (or refer to [Changing global configuration on the fly](#changing-global-configuration-on-the-fly)).

#### Destination

```ruby
EasyLogging.log_destination = 'app.log'
```

Default: `STDOUT`

Since: [v0.2.0](https://github.com/thisismydesign/easy_logging/releases/tag/v0.2.0)

#### Level

```ruby
EasyLogging.level = Logger::DEBUG
```

Default: `Logger::INFO`

Since: [v0.3.0](https://github.com/thisismydesign/easy_logging/releases/tag/v0.3.0)

#### Formatter

```ruby
EasyLogging.formatter = proc do |severity, datetime, progname, msg|
  severity + datetime + progname + msg
end
```

Default: Logger default

Since: [v0.3.0](https://github.com/thisismydesign/easy_logging/releases/tag/v0.3.0)

#### Changing global configuration on the fly

... is tricky but looking at the specs it's fairly easy to understand:

```ruby
describe 'on the fly modification of global logger configuration' do
  context 'class level logger' do
    it 'uses old config if EasyLogging was included before config change'
    it 'uses new config if EasyLogging was included after config change'
  end

  context 'instance level logger' do
    it 'uses old config if instance was created before config change'
    it 'uses new config if instance was created after config change'
  end
end
```

## Contribution and feedback

This project is built around known use-cases. If you have one that isn't covered don't hesitate to open an issue and start a discussion.

Bug reports and pull requests are welcome on GitHub at https://github.com/thisismydesign/easy_logging. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Conventions

This project follows [C-Hive guides](https://github.com/c-hive/guides) for code style, way of working and other development concerns.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
