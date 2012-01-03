shapewear [![Build Status](https://secure.travis-ci.org/elementar/shapewear.png)](http://travis-ci.org/elementar/shapewear)
=========

Make your fat service look skinny.

Work in Progress
----------------

This gem is still in early development, and it's not yet yet ready for use. Any contribution and feedback is welcome.

Installation
------------

Shapewear is available through [Rubygems](http://rubygems.org/gems/shapewear) and can be installed via:

```
$ gem install shapewear
```

Introduction
------------

First, describe your SOAP service:

``` ruby
require "shapewear"

class MyFirstService
  include Shapewear

  wsdl_namespace 'http://services.example.com/v1'
  schema_namespace 'http://schemas.example.com/v1'

  endpoint_url 'http://localhost:3000/my_first_service'

  operation :hello, :parameters => [[:name, String]], :returns => String
  def hello(name)
    "hello, #{name}"
  end

  operation :sum, :parameters => [[:x, Fixnum], [:y, Fixnum]], :returns => Fixnum
  def sum(x, y)
    x + y
  end

  operation :get_user_info, :parameters => [[:email, String]], :returns => { :name => String, :birthday => DateTime }
  def get_user_info(email)
    User.find_by_email(email)
  end
end
```

Then bind to your web application in a non-intrusive way.

Rails example:

``` ruby
# don't forget to write the appropriate routes
class MyFirstServiceController < ApplicationController
  def wsdl
    render :xml => MyHelloService.to_wsdl
  end

  def serve
    render :xml => MyHelloService.serve(params)
  end
end
```

Sinatra example:

``` ruby
class MySinatraApp < Sinatra::App
  get "my_first_service/wsdl" do
    content_type "application/xml"
    MyHelloService.to_wsdl
  end

  post "my_first_service" do
    content_type "application/xml"
    MyHelloService.serve(params)
  end
end
```
