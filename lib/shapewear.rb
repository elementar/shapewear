require 'nokogiri'

require 'shapewear/version'
require 'shapewear/logging'
require 'shapewear/dsl'
require 'shapewear/wsdl'
require 'shapewear/request'

module Shapewear
  def self.included(receiver)
    receiver.extend(Shapewear::Logging)
    receiver.extend(Shapewear::DSL)
    receiver.extend(Shapewear::WSDL)
    receiver.extend(Shapewear::Request)

    class << receiver
      def method_added(m)
        # automatically creates an operation for each method added
        operation m
      end
    end
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