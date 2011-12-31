require "spec_helper"

describe Shapewear::DSL do

  let(:xmlns) { {'wsdl' => 'http://schemas.xmlsoap.org/wsdl/', 'soap' => 'http://schemas.xmlsoap.org/wsdl/soap/'} }

  describe "basic DSL" do
    it "should describe parameterless, 'hello world' services" do
      class ParameterlessHelloWorldService
        include Shapewear::DSL

        def hello_world
          "hello"
        end
      end

      wsdl = ParameterlessHelloWorldService.to_wsdl
      puts wsdl
      wsdl_doc = nil
      expect { wsdl_doc = Nokogiri::XML(wsdl) { |c| c.strict } }.not_to raise_error

      # there should be a definition with the class' name
      wsdl_def = wsdl_doc.xpath("/wsdl:definitions[@name='ParameterlessHelloWorldService']", xmlns)
      wsdl_def.should have(1).node
      wsdl_def.xpath("wsdl:service[@name='ParameterlessHelloWorldService']/wsdl:port[@name='ParameterlessHelloWorldServicePort']/soap:address", xmlns).should have(1).node

      # the message element for the input should not be there, as the method does not accept parameters
      wsdl_def.xpath("wsdl:message[@name='HelloWorldInput']", xmlns).should have(0).node

      # the message element for the output must be there, as a simple string
      wsdl_def.xpath("wsdl:message[@name='HelloWorldOutput']/wsdl:part[@name='body']", xmlns).should have(1).node

      # there must be an operation named 'HelloWorld'
      wsdl_def.xpath("wsdl:portType/wsdl:operation[@name='HelloWorld']", xmlns).should have(1).node
      wsdl_def.xpath("wsdl:binding/wsdl:operation[@name='HelloWorld']", xmlns).should have(1).node
    end
    it "should describe services with basic parameters and return values"
    it "should describe services with array parameters"
  end

  describe "complex types DSL" do
    it "should allow definition of complex types using class introspection"
    it "should allow definition of complex types using a builder-like DSL"
    it "should accept complex types as input"
    it "should accept complex types as output"
  end

  describe "WSDL customization" do
    it "should allow customization of namespace"
  end

  describe "existing WSDL" do
    it "should accept an existing WSDL"
  end
end
