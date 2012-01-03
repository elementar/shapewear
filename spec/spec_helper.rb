require "bundler"
Bundler.require :default, :development

RSpec.configure do |config|
end

Dir[File.join File.dirname(__FILE__), 'shapewear', 'service_definitions', '*.rb'].each { |f| require f }