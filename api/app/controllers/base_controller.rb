# frozen_string_literal: true

# Clase base para los controladores de la aplicación.
class BaseController
  attr_reader :session, :request, :params

  def call(env)
    @request = Rack::Request.new(env)
    @session = env['rack.session']
    @params = build_params

    status, headers, body = route_request
    headers['content-type'] = 'application/json'
    [status, headers, [body.to_json]]
  rescue StandardError => e
    [500, { 'content-type' => 'application/json' }, { 'error' => e.message }]
  end

  def route_request
    raise NotImplementedError
  end

  def routing_info
    [@request.request_method, (@request.path_info.empty? ? '/' : @request.path_info)]
  end

  def not_found
    [404, {}, { 'error' => 'Not found' }]
  end

  def build_params
    params = {}
    input = request.body&.read || ''
    params.merge!(JSON.parse(input)) unless input.empty?
    params.merge!(request.params)
    params.deep_transform_keys { |key| key.underscore.to_sym }
  end
end
