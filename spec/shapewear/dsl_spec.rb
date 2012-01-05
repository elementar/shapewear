# encoding: UTF-8

require "spec_helper"

describe Shapewear::DSL do

  let(:xmlns) { {'wsdl' => 'http://schemas.xmlsoap.org/wsdl/', 'soap' => 'http://schemas.xmlsoap.org/wsdl/soap/'} }

  describe "basic DSL" do
    it "should describe a minimal working service" do
      wsdl = MinimalWorkingService.to_wsdl
      puts wsdl

      # wsdl should be valid XML (duh!)
      expect { Nokogiri::XML(wsdl) { |c| c.strict } }.not_to raise_error

      # wasabi should be able to parse it
      wdoc = nil
      expect { wdoc = Wasabi.document wsdl }.not_to raise_error

      wdoc.namespace.should match /MinimalWorkingService/
      wdoc.soap_actions.should == [:hello_world]

      wdoc.operations[:hello_world].should_not be_nil
      wdoc.operations[:hello_world][:input].should == 'HelloWorld'
      wdoc.operations[:hello_world][:input].should match /HelloWorld$/
    end
  end

  describe "complex types DSL" do
    it "should accept complex types as input"
    it "should accept complex types as output"
    it "should accept arrays as input"
    it "should accept arrays as output"
    it "should allow definition of complex types using class introspection"
    it "should allow definition of complex types using a DSL"
  end

  describe "WSDL customization" do
    it "should allow customization of target namespace"
    it "should allow customization of schema namespace"
  end

  describe "existing WSDL" do
    it "should accept an existing WSDL"
  end
end
