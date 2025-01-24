# frozen_string_literal: true

require 'rack'

# Middleware para la autenticación de requests.
class Auth
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    unless request.path_info.start_with? '/auth'
      user_id = env['rack.session']['user_id']
      return [401, {}, [{ 'error' => 'Unauthorized' }.to_json]] if user_id.nil? || User.find_by(id: user_id).nil?
    end
    @app.call(env)
  end
end
