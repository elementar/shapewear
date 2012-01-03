require "spec_helper"

describe Shapewear do
  describe "usage with SOAP clients" do
    before do
      FakeWeb.register_uri :get, "http://services.example.com/complete/soap/wsdl",
                           :body => CompleteService.to_wsdl, :content_type => 'application/xml'

      FakeWeb.register_uri :post, "http://services.example.com/complete/soap/wsdl",
                           :body => CompleteService.serve
    end

    it "should work with Savon" do
      client = Savon::Client.new
    end
  end
end