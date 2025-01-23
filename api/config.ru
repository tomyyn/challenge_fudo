# frozen_string_literal: true

require 'rack'
require 'rack/session/cookie'
require 'dotenv'

require './app/application'
require './app/middleware/cache_control'

Dotenv.load

use(Rack::Reloader, 0) if ENV['RACK_ENV'] == 'development'
use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           expire_after: 3600,
                           secret: ENV['SESSION_SECRET']
use CacheControl
use Rack::Static, urls: ['/'], root: 'public', cascade: true

run Application.new
