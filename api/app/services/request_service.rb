# frozen_string_literal: true

require 'net/http'

# Servicio para el envío de requests HTTP.
class RequestService
  def initialize(uri, method, headers = {}, body = {})
    @uri = uri
    @method = method
    @headers = headers
    @body = body
  end

  def execute
    uri = URI.parse(@uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP.const_get(@method.capitalize).new(uri.path || '/', @headers)
    request.body = @body.to_json

    http.request(request)
  rescue ArgumentError
    nil
  end
end
