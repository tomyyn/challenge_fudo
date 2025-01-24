# frozen_string_literal: true

require 'rack'
require 'rack/session/cookie'
require 'dotenv'
require 'require_all'

require './app/application'
require_all './app/middleware'
require_all './app/controllers'
require_all './lib'

Dotenv.load

use(Rack::Reloader, 0) if ENV['RACK_ENV'] == 'development'
use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           expire_after: 3600,
                           secret: ENV.fetch('SESSION_SECRET', nil)
use CacheControl
use Rack::Deflater
use Rack::Static, urls: ['/AUTHORS', '/openapi.yaml'], root: 'public', cascade: true
use Auth

app = Rack::URLMap.new(
  '/auth' => AuthController.new,
  '/products' => ProductsController.new,
  '/' => Application.new # Controller de debug, borrar luego.
)

run app
