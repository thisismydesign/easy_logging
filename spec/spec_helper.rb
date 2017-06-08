require "bundler/setup"

require "coveralls"
Coveralls.wear!

require "easy_logging"

require_relative 'spec_support.rb'
include SpecSupport

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSPEC_ROOT = File.dirname __FILE__
