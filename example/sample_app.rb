# -------------------------------------------
# To run the application: ruby examples/sample_app.rb
# -------------------------------------------

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'rails', '5.0.0'
  gem 'exception_notification', '4.4.0'
  gem 'exception_notification_telegram', path: '../../exception_notification_telegram'
end

class SampleApp < Rails::Application
  config.middleware.use ExceptionNotification::Rack,
                        telegram: {
                          token: ENV['TOKEN'],
                          channel: ENV['CHANNEL']
                        }

  config.secret_key_base = 'my secret key base'
  file = File.open('sample_app.log', 'w')
  logger = Logger.new(file)
  Rails.logger = logger

  routes.draw do
    get 'raise_sample_exception', to: 'exceptions#raise_sample_exception'
  end
end

require 'action_controller/railtie'
require 'active_support'

class ExceptionsController < ActionController::Base
  include Rails.application.routes.url_helpers

  def raise_sample_exception
    puts 'Raising exception!'
    raise 'Sample exception raised, you should receive a notification!'
  end
end

require 'minitest/autorun'

class Test < Minitest::Test
  include Rack::Test::Methods

  def test_raise_exception
    get '/raise_sample_exception'
    puts 'Working OK!'
  end

  private

  def app
    Rails.application
  end
end
