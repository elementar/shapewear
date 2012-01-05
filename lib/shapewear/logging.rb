# encoding: UTF-8

module Shapewear::Logging
  def logger
    @logger ||= (::Rails.logger rescue Logger.new(STDOUT))
  end

  def logger=(logger)
    @logger = logger
  end
end