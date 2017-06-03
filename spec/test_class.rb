class TestClass
  include EasyLogging

  def log_info(msg)
    logger.info(msg)
  end

  def self.log_info(msg)
    logger.info(msg)
  end
end
