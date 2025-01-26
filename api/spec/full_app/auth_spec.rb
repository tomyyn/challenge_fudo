# frozen_string_literal: true

require 'spec_helper'
require './app/models/user'

RSpec.describe 'Auth', type: :request, openapi: { tags: ['Auth'] } do
  def app
    full_app
  end

  before { User.instance_variable_set(:@users, [{ id: 0, username: 'tomyyn', password: '12345678' }]) }

  describe '#login', openapi: {
    summary: 'User login',
    description: 'Logs in a user, setting the session cookie when a correct combination of username and password is provided.'
  } do
    before { env 'rack.session', { 'user_id' => nil } }
    it 'Logs in successfully if credentials are corret' do
      post '/auth/login', { username: 'tomyyn', password: '12345678' }.to_json
      expect(last_response.status).to eq 200
      expect(last_response.body).to match_response_schema('shared', 'message')
    end

    it "Doesn't log in if credentials are wrong",
       openapi: { description: 'Returns a 401 error if the provided credentials are wrong.' } do
      post '/auth/login', { username: 'tomyyn', password: '123123' }.to_json
      expect(last_response.status).to eq 401
      expect(last_response.body).to match_response_schema('shared', 'error')
    end

    it "Doesn't log in if user is already logged in or if either username or password is missing",
       openapi: { description: 'Returns a 422 error if credentials are missing or the user is already logged in' } do
      env 'rack.session', { 'user_id' => 0 }
      post '/auth/login', { username: 'tomyyn', password: '12345678' }.to_json
      expect(last_response.status).to eq 422
      expect(last_response.body).to match_response_schema('shared', 'error')
    end
  end
end
