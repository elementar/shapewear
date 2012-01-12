# encoding: UTF-8

require 'builder'

module Shapewear::DSL
  private

  def options
    @options ||= { :service_name => self.name }
  end

  def operations
    options[:operations] ||= {}
  end

  def namespaces
    options[:namespaces] ||=
      Hash.new { |_, k| raise "Namespace not defined: #{k}" } \
        .merge! 'tns' => "http://services.example.com/#{self.name}",
                'wsdl' => 'http://schemas.xmlsoap.org/wsdl/',
                'soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                'soap12' => 'http://schemas.xmlsoap.org/wsdl/soap12/',
                'xsd' => 'http://www.w3.org/2001/XMLSchema',
                'env' => 'http://schemas.xmlsoap.org/soap/envelope/',
                'env12' => 'http://www.w3.org/2001/12/soap-envelope'
  end

  protected

  def service_name(sn)
    options[:service_name] = sn
  end

  def wsdl_namespace(ns)
    namespaces['tns'] = ns
  end

  def endpoint_url(url)
    options[:endpoint_url] = url
  end

  def operation(name, ops = {})
    h = (operations[name] ||= {}).merge! ops
    h[:public_name] ||= name.to_s.camelize
  end
end
