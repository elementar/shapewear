# encoding: UTF-8

require 'builder'

#noinspection RubyArgCount,RubyResolve
module Shapewear::WSDL
  # reference: http://www.w3.org/TR/wsdl
  def to_wsdl
    xm = Builder::XmlMarkup.new

    xm.instruct!
    xm.definitions :name => self.name, 'targetNamespace' => namespaces['tns'],
                   'xmlns' => namespaces['wsdl'],
                   'xmlns:soap' => namespaces['soap'],
                   'xmlns:xsd1' => namespaces['xsd1'],
                   'xmlns:tns' => namespaces['tns'] do |xdef|

      xdef.types do |xtypes|
        xtypes.schema 'xmlns' => namespaces['xsd'], 'targetNamespace' => namespaces['xsd1'] do |xschema|

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
          xmsg.part :name => :body, :element => "xsd1:#{m.camelize}Response"
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
        xbind.tag! 'soap:binding', :style => 'rpc', :transport => 'http://schemas.xmlsoap.org/soap/http'
        operations.each do |op, op_opts|
          xbind.operation :name => op_opts[:public_name] do |xop|
            doc = op_opts[:documentation] rescue nil
            xop.documentation doc unless doc.nil?
            xop.tag! 'soap:operation', :soapAction => "#{namespaces['tns']}/#{op_opts[:public_name]}"
            xop.input { |xin| xin.tag! 'soap:body', :use => 'literal', :namespace => namespaces['tns'] } unless instance_method(op).arity == 0
            xop.output { |xin| xin.tag! 'soap:body', :use => 'literal', :namespace => namespaces['tns'] }
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
    op_options = options[:operations][m.to_sym] rescue nil

    if um.arity > 0
      xschema.element :name => "#{op_options[:public_name]}Request" do |xreq|
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
              t = p.last
              if t.nil?
                xall.element :name => p.first, :type => 'xsd:any'
              elsif t.is_a?(Class)
                xall.element :name => p.first, :type => to_xsd_type(t)
              elsif t.is_a?(Hash)
                xall.complexType do |xct2|
                  xct2.all do |xall2|
                    t.each do |name, type|
                      xall2.element :name => name, :type => to_xsd_type(type)
                    end
                  end
                end
              else
                raise "Could not interpret #{t.inspect} as a return type definition"
              end
            end
          end
        end
      end
    end

    # element for method result
    xschema.element :name => "#{op_options[:public_name]}Response" do |xreq|
      xreq.complexType do |xct|
        xct.all do |xall|
          ret = op_options[:returns] rescue nil
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

  # @param t [Class]
  def to_xsd_type(t)
    return 'xsd:string' if t == String
    return 'xsd:integer' if t == Fixnum
    return 'xsd:dateTime' if t == DateTime
    return 'xsd:any' if t.nil? || t == Object
    raise "Could not convert type #{t} to a valid XSD type"
  end
end
