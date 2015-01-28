# Generated by cucumber-sinatra. (2014-08-18 13:58:33 -0500)
require 'capybara/poltergeist'
require 'capybara-screenshot/cucumber'
ENV['RACK_ENV'] = 'test'
ENV["HTTP_ACCEPT"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
require File.join(File.dirname(__FILE__), '..', '..', 'app/overlord.rb')

# require 'rubygems'
# require 'bundler/setup'
Bundler.require(:test)

Capybara.app = Overlord

Capybara.default_selector = :css
Capybara.javascript_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
    options = {
        :js_errors => true,
        :timeout => 120,
        :debug => true,
        :phantomjs_options => ['--load-images=no', '--disk-cache=false'],
        :inspector => true,
    }
    Capybara::Poltergeist::Driver.new(app, options)
end
WebMock.disable_net_connect!(:allow_localhost => true)
Before('@javascript') do
  WebMock.allow_net_connect!
end

After do
  Timecop.return
end
include Capybara::Angular::DSL
include Rack::Test::Methods



World(Rack::Test::Methods)
