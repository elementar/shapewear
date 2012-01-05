# encoding: UTF-8

require 'builder'

module Shapewear::DSL
  private

  def options
    @options ||= {}
  end

  def operations
    options[:operations] ||= {}
  end

  def namespaces
    options[:namespaces] ||=
      Hash.new { |_, k| raise "Namespace not defined: #{k}" } \
        .merge! 'tns' => "http://services.example.com/#{self.name}",
                'xsd1' => "http://schema.example.com/#{self.name}",
                'wsdl' => 'http://schemas.xmlsoap.org/wsdl/',
                'soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                'xsd' => 'http://www.w3.org/2001/XMLSchema',
                'env' => 'http://schemas.xmlsoap.org/soap/envelope/'
  end

  protected

  def wsdl_namespace(ns)
    namespaces['tns'] = ns
  end

  def schema_namespace(ns)
    namespaces['xsd1'] = ns
  end

  def endpoint_url(url)
    options[:endpoint_url] = url
  end

  def operation(name, ops = {})
    h = (operations[name] ||= {}).merge! ops
    h[:public_name] ||= name.to_s.camelize
  end
end
