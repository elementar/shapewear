# encoding: UTF-8

# This class represents a fully customized service.
# It is used to test the extensiveness of the Shapewear DSL.
class CompleteService
  include Shapewear

  wsdl_namespace 'http://services.example.com/v1'
  schema_namespace 'http://schemas.example.com/v1'

  endpoint_url 'http://services.example.com/complete/soap'

  operation :echo_in_uppercase, :documentation => 'Echoes back the parameter, in uppercase',
            :parameters => [[:text, String]], :returns => String

  operation :sum, :documentation => 'Adds two numbers',
            :parameters => [[:x, Fixnum], [:y, Fixnum]],
            :returns => Fixnum

  operation :get_structured_data, :documentation => 'Returns structured data. 0 uses a Hash, 1 uses a struct, any other value raises a fault',
            :parameters => [[:id, Fixnum]],
            :returns => {:text => String, :random_value => Fixnum, :created_at => DateTime}

  def echo_in_uppercase(text)
    text.upcase
  end

  def sum(x, y)
    x + y
  end

  def get_structured_data(id)
    case id
      when 0 then
        Structured.new('text from the struct')
      when 1 then
        {:text => 'text from a hash', :random_value => rand(999), @created_at => DateTime.now}
      else
        raise "ID must be 0 or 1"
    end
  end

  def reset(chave)
    raise "Operação não permitida" if ::Rails.env.production?
    c = Conector::Registro.find_by_chave_registro(chave)
    c.reset!

    'ok'
  end

  class Structured < Struct.new(:text, :random_value, :created_at)
    def initialize(text)
      @text = text
      @random_value = rand(999)
      @created_at = DateTime.now
    end
  end
end
