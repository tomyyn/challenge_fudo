# frozen_string_literal: true

require 'rack'

# Middleware para personalizar el header Cache-Control de determinadas respuestas.
class CacheControl
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    case env['PATH_INFO']
    when '/AUTHORS'
      headers['cache-control'] = 'public, max-age=86400'
    when '/openapi.yaml'
      headers['cache-control'] = 'no-store'
    end

    [status, headers, body]
  end
end
