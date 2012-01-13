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
          params = extract_parameters(v, op_node)
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

    def extract_parameters(op_options, node)
      logger.debug "Operation node: #{node.inspect}"
      r = []
      op_options[:parameters].each do |p|
        logger.debug "  Looking for: tns:#{p.first.camelize_if_symbol(false)}"
        v = node.xpath("tns:#{p.first.camelize_if_symbol(false)}", namespaces).first
        if v.nil?
          # does nothing
        elsif p.last == Fixnum
          v = v.text.to_i
        elsif p.last == DateTime
          v = DateTime.parse(v.text) # TODO: add tests
        else
          v = v.text
        end
        logger.debug "    Found: #{v.inspect}"
        r << v
      end
      r
    end

    #noinspection RubyArgCount
    def serialize_soap_result(op_options, r)
      xb = Builder::XmlMarkup.new
      xb.instruct!

      xb.Envelope :xmlns => soap_env_ns, 'xmlns:xsi' => namespaces['xsi'] do |xenv|
        xenv.Body do |xbody|
          xbody.tag! "#{op_options[:public_name]}Response", :xmlns => namespaces['tns'] do |xresp|

            if r.nil?
              xresp.tag! "#{op_options[:public_name]}Result", 'xsi:nil' => 'true'
            else
              ret = op_options[:returns] rescue nil
              case ret
                when NilClass, Class
                  xresp.tag! "#{op_options[:public_name]}Result", r
                when Hash
                  xresp.tag! "#{op_options[:public_name]}Result" do |xres|
                    ret.each do |k, v|
                      extract_and_serialize_value(xres, r, k, v)
                    end
                  end
                else
                  raise "Unsupported return type: #{ret.inspect}"
              end
            end
          end
        end
      end
    end

    def extract_and_serialize_value(builder, obj, field, type)
      v = if obj.is_a?(Hash)
        obj[field]
      elsif obj.respond_to?(field)
        obj.send(field)
      elsif obj.respond_to?(field.underscore)
        obj.send(field.underscore)
      else
        raise "Could not extract #{field.inspect} from object: #{obj.inspect}"
      end

      if v.nil?
        builder.tag! field.camelize_if_symbol, 'xsi:nil' => 'true'
      else
        builder.tag! field.camelize_if_symbol, v
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
