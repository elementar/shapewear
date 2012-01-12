# encoding: UTF-8

require "spec_helper"

describe Shapewear do
  describe "usage with SOAP clients" do
    before do
      stub_request(:get, "http://services.example.com/complete/soap/wsdl") \
        .to_return :body => CompleteService.to_wsdl, :headers => { 'Content-Type' => 'application/xml' }

      stub_request(:post, "http://services.example.com/complete/soap") \
        .to_return :body => lambda { |r| CompleteService.serve(r) }, :headers => { 'Content-Type' => 'application/xml' }
    end

    describe "Savon" do
      it "should work for simple requests" do
        client = Savon::Client.new 'http://services.example.com/complete/soap/wsdl'
        response = client.request :echo_in_uppercase, :xmlns => 'http://services.example.com/v1' do
          soap.body = { :text => 'uppercase text' }
        end

        puts response.inspect
        puts response.body.inspect

        response.body[:echo_in_uppercase_response][:body].should == 'UPPERCASE TEXT'
      end

      it "should raise SOAP 1.1 Faults" do
        client = Savon::Client.new 'http://services.example.com/complete/soap/wsdl'

        expect {
          client.request :get_structured_data, :xmlns => 'http://services.example.com/v1' do
            soap.body = { :id => 55 }
          end
        }.to raise_error Savon::SOAP::Fault, "(e:Server.RuntimeError) ID must be 0 or 1"
      end

      it "should raise SOAP 1.2 Faults" do
        client = Savon::Client.new 'http://services.example.com/complete/soap/wsdl'

        expect {
          client.request :get_structured_data, :xmlns => 'http://services.example.com/v1' do
            soap.version = 2
            soap.body = { :id => 55 }
          end
        }.to raise_error Savon::SOAP::Fault, "(e:Server.RuntimeError) ID must be 0 or 1"
      end
    end
  end
end