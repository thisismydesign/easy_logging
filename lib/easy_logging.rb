require 'logger'

require_relative "easy_logging/version"

module EasyLogging
  def logger
    EasyLogging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.included(base)
    class << base
      def logger
        EasyLogging.logger
      end
    end
  end
end
