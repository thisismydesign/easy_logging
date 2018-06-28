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
    attr_reader :log_destination
    attr_accessor :level, :formatter, :logger_init_params
  end

  @loggers = {}
  @logger_init_params = [STDOUT, level: Logger::INFO]

  def self.logger_params(*params)
    p params
    @logger_init_params = params
    # TODO: other default settings should not overwrite logger params setting (e.g. level, etc)
    @log_destination = @logger_init_params[0]
  end

  def self.log_destination=(dest)
    @logger_init_params = @logger_init_params.drop(1).unshift(dest)
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
    base.send(:logger)
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger_for(classname)
    @loggers[classname] ||= configure_logger_for(classname)
  end

  def self.configure_logger_for(classname)
    logger = Logger.new(*@logger_init_params)
    logger.level = @level unless @level.nil?
    logger.progname = classname
    logger.formatter = formatter unless formatter.nil?
    logger
  end

  private

  def logger
    @logger ||= EasyLogging.logger_for(self.class.name)
  end

end
