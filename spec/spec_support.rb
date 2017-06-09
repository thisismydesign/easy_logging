module SpecSupport

  def mocked_env_with(dict)
    ENV.to_h.merge(dict)
  end

  def get_device(logger)
    logger.instance_variable_get(:@logdev).instance_variable_get(:@dev)
  end

end
