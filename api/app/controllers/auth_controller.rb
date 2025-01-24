# frozen_string_literal: true

require_relative 'base_controller'
require './app/models/user'

# Controlador para la autenticación de usuarios.
class AuthController < BaseController
  private

  def route_request
    case routing_info
    when ['POST', '/login']
      login
    else
      not_found
    end
  end

  def login
    return [422, {}, [{ 'error' => 'you are already logged in' }]] unless session['user_id'].nil?

    if params[:username].nil? || params[:password].nil?
      return [422, {},
              [{ 'error' => 'username and password are required' }]]
    end

    user = User.find_by(username: params[:username], password: params[:password])
    if user.nil?
      [401, {}, [{ 'error' => 'Invalid username or password' }]]
    else
      session['user_id'] = user.id
      [200, {}, [{ 'message' => 'Logged in successfull' }]]
    end
  end
end
