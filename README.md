shapewear [![Build Status](https://secure.travis-ci.org/elementar/shapewear.png)](http://travis-ci.org/elementar/shapewear)
=========

Make your fat service look skinny.

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
  include Shapewear::DSL

  def hello(name)
    "hello, #{name}"
  end

  def sum(x, y)
    x + y
  end
end
```

Then bind to your web application in a non-intrusive way.

Rails example:

``` ruby
# don't forget to write the appropriate routes
class MyFirstServiceController
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
