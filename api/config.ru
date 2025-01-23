# frozen_string_literal: true

require 'rack'
require './app/application'
require './app/middleware/cache_policy'

use(Rack::Reloader, 0) if ENV['RACK_ENV'] == 'development'

use CacheControl
use Rack::Static, urls: ['/'], root: 'public', cascade: true

run Application.new
