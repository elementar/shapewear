require 'builder'

module Shapewear
  #noinspection RubyArgCount,RubyResolve
  module WSDL
    # reference: http://www.w3.org/TR/wsdl
    def to_wsdl
      tns = options[:wsdl_namespace] || "http://shapewear.elementarsistemas.com.br/auto/#{self.name}.wsdl"
      xsd = options[:schema_namespace] || "http://shapewear.elementarsistemas.com.br/auto/#{self.name}.xsd"

      xm = Builder::XmlMarkup.new

      xm.instruct!
      xm.definitions :name => self.name, 'targetNamespace' => tns,
                     'xmlns' => 'http://schemas.xmlsoap.org/wsdl/',
                     'xmlns:soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                     'xmlns:xsd1' => xsd, 'xmlns:tns' => tns do |xdef|

        xdef.types do |xtypes|
          xtypes.schema 'xmlns' => 'http://www.w3.org/2000/10/XMLSchema', 'targetNamespace' => xsd do |xschema|

            # define elements for each defined method
            instance_methods(false).each do |m|
              build_type_elements_for_method(m, xschema)
            end
          end
        end

        instance_methods(false).each do |m|
          xdef.message :name => "#{m.camelize}Input" do |xmsg|
            xmsg.part :name => :body, :element => "xsd1:#{m.camelize}Request"
          end unless instance_method(m).arity == 0
          xdef.message :name => "#{m.camelize}Output" do |xmsg|
            xmsg.part :name => :body, :element => "xsd1:#{m.camelize}"
          end
        end

        xdef.portType :name => "#{self.name}PortType" do |xpt|
          instance_methods(false).each do |m|
            xpt.operation :name => m.camelize do |xop|
              xop.input :message => "tns:#{m.camelize}Input" unless instance_method(m).arity == 0
              xop.output :message => "tns:#{m.camelize}Output"
            end
          end
        end

        xdef.binding :name => "#{self.name}Binding", :type => "tns:#{self.name}PortType" do |xbind|
          xbind.tag! 'soap:binding', :style => 'document', :transport => 'http://schemas.xmlsoap.org/soap/http'
          instance_methods(false).each do |m|
            xbind.operation :name => m.camelize do |xop|
              xop.tag! 'soap:operation', :soapAction => "#{tns}/#{m.camelize}"
              xop.input { |xin| xin.tag! 'soap:body', :use => 'literal' } unless instance_method(m).arity == 0
              xop.output { |xin| xin.tag! 'soap:body', :use => 'literal' }
            end
          end
        end

        xdef.service :name => self.name do |xsrv|
          xsrv.documentation "WSDL auto-generated by shapewear."
          xsrv.port :name => "#{self.name}Port", :binding => "#{self.name}Binding" do |xport|
            xport.tag! 'soap:address', :location => options[:endpoint_url]
          end
        end
      end
    end

    def build_type_elements_for_method(m, xschema)
      # element for method arguments
      um = instance_method(m)
      op_options = options[:operations][m.to_sym]

      if um.arity > 0
        xschema.element :name => "#{m.camelize}Request" do |xreq|
          xreq.complexType do |xct|
            xct.all do |xall|
              params = op_options[:parameters] rescue nil
              if params.nil?
                if um.respond_to?(:parameters)
                  # with Ruby 1.9, we can create the parameters with the correct names
                  params = um.parameters.select { |p| p.first == :in }.map { |p| [p.first, Object] }
                else
                  params = (0..um.arity).map { |i| ["arg#{i}", Object] }
                end
              end

              params.each do |p|
                xall.element :name => p.first, :type => to_xsd_type(p.last)
              end
            end
          end
        end
      end

      # element for method result
      xschema.element :name => "#{m.camelize}" do |xreq|
        xreq.complexType do |xct|
          xct.all do |xall|
            ret = op_options[:returns]
            if ret.nil?
              xall.element :name => 'result', :type => 'xsd:any'
            elsif ret.is_a?(Class)
              xall.element :name => 'result', :type => to_xsd_type(ret)
            elsif ret.is_a?(Hash)
              ret.each do |name, type|
                xall.element :name => name, :type => to_xsd_type(type)
              end
            else
              raise "Could not interpret #{ret.inspect} as a return type definition"
            end
          end
        end
      end
    end

    def to_xsd_type(t)
      if t.is_a?(Class)
        return 'xsd:string' if t == String
        return 'xsd:integer' if t == Fixnum
        return 'xsd:any' if t == Object
        raise "Could not convert type #{t} to a valid XSD type"
      elsif t.is_a?(Hash)
        '??'
      end
    end
  end
end
