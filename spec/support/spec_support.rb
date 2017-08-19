module SpecSupport

  def get_device(logger)
    logger.instance_variable_get(:@logdev).instance_variable_get(:@dev)
  end

end
