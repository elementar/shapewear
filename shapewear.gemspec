lib = File.expand_path("../lib", __FILE__)
$:.unshift lib unless $:.include? lib

require 'soapbox/version'

Gem::Specification.new do |s|
  s.name        = "shapewear"
  s.version     = Soapbox::Version
  s.authors     = "Fábio Batista"
  s.email       = "fabio@elementarsistemas.com.br"
  s.homepage    = "https://github.com/elementar/shapewear"
  s.summary     = "Make your fat service look skinny"
  s.description = "Shapewear is a Ruby library for handling SOAP requests from within your Rails or Sinatra application. It makes your fat services look skinny."

  s.rubyforge_project = s.name

  s.add_dependency "builder",  ">= 2.1.2"
  s.add_dependency "nokogiri", ">= 1.4.0"

  s.add_development_dependency "rake",    "~> 0.8.7"
  s.add_development_dependency "rspec",   "~> 2.5.0"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
