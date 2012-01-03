require 'builder'

module Shapewear
  module DSL
    private

    def options
      @options ||= {}
    end

    protected

    def wsdl_namespace(ns)
      options[:wsdl_namespace] = ns
    end

    def schema_namespace(ns)
      options[:schema_namespace] = ns
    end

    def endpoint_url(url)
      options[:endpoint_url] = url
    end

    def operation(name, ops = {})
      (options[:operations] ||= {})[name] = ops
    end
  end
end
