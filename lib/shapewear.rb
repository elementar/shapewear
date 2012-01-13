# encoding: UTF-8

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

# defines String.camelize and String.underscore, if it is not defined by, e.g. Rails
class String
  unless ''.respond_to? :camelize
    def camelize(first_letter = :upper)
      if first_letter == :upper
        self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        self[0].chr.downcase + self.camelize[1..-1]
      end
    end
  end

  unless ''.respond_to? :underscore
    def underscore
      word = self.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end

class Object
  def camelize_if_symbol(first_letter = :upper)
    if self.is_a?(Symbol)
      self.to_s.camelize(first_letter)
    else
      self.to_s
    end
  end
end
