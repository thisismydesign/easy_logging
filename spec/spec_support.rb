module SpecSupport

  def mocked_env_with(dict)
    clone = ENV.clone
    dict.each_pair do |k,v|
      clone[k]=v
    end
    clone
  end

end
