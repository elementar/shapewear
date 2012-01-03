require 'nokogiri'

require 'shapewear/version'
require 'shapewear/dsl'
require 'shapewear/wsdl'

module Shapewear
  def self.included(receiver)
    receiver.extend(Shapewear::DSL)
    receiver.extend(Shapewear::WSDL)
  end
end

# defines String.camelize if it is not defined by, e.g. Rails
unless ''.respond_to? :camelize
  class String
    def camelize
      self.split('_').map(&:capitalize).join
    end
  end
end