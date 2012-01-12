# encoding: UTF-8

module Shapewear::Request
  # @param request [Rack::Request, Hash]
  def serve(request)
    op_node = find_soap_operation_node(request)

    begin
      call_soap_operation(op_node)
    rescue => e
      serialize_soap_fault e
    end
  end

  private

  def find_soap_operation_node(request)
    body ||= request.body if request.respond_to? :body
    body ||= request[:body] if request.is_a?(Hash)
    body ||= request.to_s

    raise "Request body could not be found" if body.nil?

    doc = Nokogiri::XML(body) { |c| c.strict } rescue raise("Request body is not a valid XML")

    raise "Request is not a SOAP::Envelope: #{body}" if doc.at('/env:Envelope', namespaces).nil?

    # find the operation element, or raise if not found
    doc.at("/env:Envelope/env:Body/tns:*", namespaces) or raise "Operation not found"
  end

  def call_soap_operation(node)
    operations.each do |k, v|
      if v[:public_name] == node.name
        params = extract_parameters(node)
        logger.debug "Calling #{k} with args: #{params.map(&:inspect) * ', '}"
        r = self.new.send(k, *params)
        logger.debug "Result: #{r.inspect}"
        return serialize_soap_result v, r
      end
    end

    raise "Operation not found: #{node.name}"
  end

  def extract_parameters(node)
    # TODO: use the metadata collected from the DSL to reoder the parameters and perform the appropriate conversions
    node.children.map { |n| n.text }
  end

  #noinspection RubyArgCount
  def serialize_soap_result(op_options, r)
    xb = Builder::XmlMarkup.new
    xb.instruct!

    xb.Envelope :xmlns => namespaces['env'] do |xenv|
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

    xb.Envelope :xmlns => namespaces['env'] do |xenv|
      xenv.Body do |xbody|
        xbody.Fault do |xf|
          xf.faultcode e.class.name
          xf.faultstring e.message
        end
      end
    end
  end
end
