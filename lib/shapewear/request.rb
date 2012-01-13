# encoding: UTF-8

require 'forwardable'

module Shapewear::Request
  # @param request [Rack::Request, Hash]
  def serve(request)
    RequestHandler.new(self, request).serve
  end

  class RequestHandler
    extend Forwardable

    attr_reader :soap_version, :op_node, :clazz
    def_delegators :@clazz, :namespaces, :operations, :logger

    def initialize(clazz, request)
      @clazz = clazz

      body ||= request.body if request.respond_to? :body
      body ||= request[:body] if request.is_a?(Hash)
      body ||= request.to_s

      raise "Request body could not be found" if body.nil?

      doc = Nokogiri::XML(body) { |c| c.strict } rescue raise("Request body is not a valid XML")

      # detect the SOAP version from the envelope, and find the operation element, or raise if not found
      if doc.at('/env:Envelope', namespaces)
        @soap_version = :soap11
        @op_node = doc.at("/env:Envelope/env:Body/tns:*", namespaces)
      elsif doc.at('/env12:Envelope', namespaces)
        @soap_version = :soap12
        @op_node = doc.at("/env12:Envelope/env12:Body/tns:*", namespaces)
      else
        raise "Request is not a SOAP 1.1 nor SOAP 1.2 Envelope: #{body}"
      end
    end

    def serve
      call_soap_operation
    end

    private

    def call_soap_operation
      raise "Operation node not found" if op_node.nil?

      operations.each do |k, v|
        if v[:public_name] == op_node.name
          logger.debug "Extracting parameters from operation node..."
          params = extract_parameters(@op_node)
          logger.debug "Creating new instance of #{clazz}..."
          obj = clazz.new
          logger.debug "Calling #{k} with args: #{params.map(&:inspect) * ', '}"
          begin
            r = obj.send(k, *params)
            logger.debug "Result: #{r.inspect}"
            return serialize_soap_result v, r
          rescue => e
            logger.debug "Exception: #{e.inspect}"
            return serialize_soap_fault e
          end
        end
      end

      raise "Operation not found: #{@op_node.name}"
    end

    def extract_parameters(node)
      # TODO: use the metadata collected from the DSL to reoder the parameters and perform the appropriate conversions
      node.children.map { |n| n.text }
    end

    #noinspection RubyArgCount
    def serialize_soap_result(op_options, r)
      xb = Builder::XmlMarkup.new
      xb.instruct!

      xb.Envelope :xmlns => soap_env_ns do |xenv|
        xenv.Body do |xbody|
          xbody.tag! "#{op_options[:public_name]}Response", :xmlns => namespaces['tns'] do |xres|
            xres.body r
          end
        end
      end
    end

    #noinspection RubyArgCount
    def serialize_soap_fault(ex)
      logger.debug "Serializing SOAP Fault: #{ex.inspect}"

      xb = Builder::XmlMarkup.new
      xb.instruct!

      xb.tag! 'e:Envelope', 'xmlns:e' => soap_env_ns do |xenv|
        xenv.tag! 'e:Body' do |xbody|
          xbody.tag! 'e:Fault' do |xf|
            case soap_version
              when :soap11
                xf.faultcode "e:Server.#{ex.class.name}"
                xf.faultstring ex.message
              when :soap12
                xf.tag! 'e:Code' do |xcode|
                  xcode.tag! 'e:Value', 'e:Receiver'
                  xcode.tag! 'e:Subcode' do |xsubcode|
                    xsubcode.tag! 'e:Value', ex.class.name
                  end
                end
                xf.tag! 'e:Reason', ex.message
              else
                raise "Unsupported SOAP version: #{soap_version}"
            end
          end
        end
      end
    end

    def soap_env_ns
      case soap_version
        when :soap11
          namespaces['env']
        when :soap12
          namespaces['env12']
        else
          raise "Unrecognized SOAP version: #{soap_version}"
      end
    end
  end
end
