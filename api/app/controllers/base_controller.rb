# frozen_string_literal: true

# Clase base para los controladores de la aplicación.
class BaseController
  attr_reader :session, :request

  def call(env)
    @request = Rack::Request.new(env)
    @session = env['rack.session']

    status, headers, body = route_request
    headers['content-type'] = 'application/json'
    [status, headers, [body.to_json]]
  end

  def route_request
    raise NotImplementedError
  end

  def not_found
    [404, {}, [{ 'error' => 'Not found' }]]
  end
end
