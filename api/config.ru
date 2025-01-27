# frozen_string_literal: true

require 'rack'
require 'rack/session/cookie'
require 'dotenv'
require 'require_all'

require_all './app/middleware'
require_all './app/controllers'
require_all './lib'

Dotenv.load

# Activa reloader en desarrollo.
use(Rack::Reloader, 0) if ENV['RACK_ENV'] == 'development'

# Manejo de cookie de sesión.
use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           expire_after: 3600,
                           secret: ENV.fetch('SESSION_SECRET', nil)

# Cache-control personalizado.
use CacheControl

# Compresión.
use Rack::Deflater

# Manejo de archivos estáticos.
use Rack::Static, urls: ['/AUTHORS', '/openapi.yaml'], root: 'public', cascade: true

# Autenticación.
use Auth

app = Rack::URLMap.new(
  '/auth' => AuthController.new,
  '/products' => ProductsController.new
)

run app
