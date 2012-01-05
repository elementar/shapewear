require "spec_helper"

describe Shapewear do
  describe "usage with SOAP clients" do
    before do
      stub_request(:get, "http://services.example.com/complete/soap/wsdl") \
        .to_return :body => CompleteService.to_wsdl, :headers => {'Content-Type' => 'application/xml'}

      stub_request(:post, "http://services.example.com/complete/soap") \
        .to_return :body => lambda { |r| CompleteService.serve(r) }, :headers => {'Content-Type' => 'application/xml'}
    end

    it "should work with Savon" do
      client = Savon::Client.new 'http://services.example.com/complete/soap/wsdl'
      response = client.request :echo_in_uppercase, :xmlns => 'http://services.example.com/v1' do
        soap.body = {:text => 'uppercase text'}
      end

      response.text.should == 'UPPERCASE TEXT'
    end
  end
end