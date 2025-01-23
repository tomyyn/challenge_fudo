# frozen_string_literal: true

require 'rack'
require './app/application'

use(Rack::Reloader, 0) if ENV['RACK_ENV'] == 'development'

run Application.new
