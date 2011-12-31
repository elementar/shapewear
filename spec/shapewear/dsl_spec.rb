require "spec_helper"

describe Shapewear::DSL do
  describe "basic DSL" do
    it "should describe parameterless, 'hello world' services"
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
