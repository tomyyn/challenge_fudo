# frozen_string_literal: true

require 'byebug'

# Clase base para los controladores de la aplicación.
class BaseController
  attr_reader :session, :request, :params

  def call(env)
    @request = Rack::Request.new(env)
    @session = env['rack.session']
    input = env['rack.input'].read
    @params = input.empty? ? {} : JSON.parse(input).deep_transform_keys { |key| key.underscore.to_sym }

    status, headers, body = route_request
    headers['content-type'] = 'application/json'
    [status, headers, [body.to_json]]
  rescue StandardError => e
    [500, { 'content-type' => 'application/json' }, [{ 'error' => e.message }]]
  end

  def route_request
    raise NotImplementedError
  end

  def routing_info
    [@request.request_method, @request.path_info]
  end

  def not_found
    [404, {}, [{ 'error' => 'Not found' }]]
  end
end
