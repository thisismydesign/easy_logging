require 'logger'

require_relative "easy_logging/version"

module EasyLogging

  module Initializer
    # Initialize instance level logger at the time of instance creation
    def initialize(*params)
      super
      logger
    end
  end

  class << self
    attr_reader :init_params, :log_destination
    attr_accessor :level, :formatter
  end

  @log_destination = STDOUT
  @init_params = [@log_destination]
  @level = Logger::INFO
  @loggers = {}

  def self.init(*params)
    @init_params = params
    @log_destination = params[0]
  end

  def self.log_destination=(dest)
    @log_destination = dest
    @init_params = @init_params.drop(1).unshift(dest)
  end

  def self.level=(level)
    @level = level
  end

  private_class_method

  # Executed when the module is included. See: https://stackoverflow.com/a/5160822/2771889
  def self.included(base)
    base.send :prepend, Initializer
    # Class level private logger method for includer class (base)
    class << base
      private
      def logger
        @logger ||= EasyLogging.logger_for(self)
      end
    end

    # Initialize class level logger at the time of including
    base.send (:logger)
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger_for(classname)
    @loggers[classname] ||= configure_logger_for(classname)
  end

  def self.configure_logger_for(classname)
    logger = Logger.new(*init_params)
    logger.level = level
    logger.progname = classname
    logger.formatter = formatter unless formatter.nil?
    logger
  end

  private

  def logger
    @logger ||= EasyLogging.logger_for(self.class.name)
  end

end
