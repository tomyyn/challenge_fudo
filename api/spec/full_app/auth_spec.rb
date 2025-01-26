# frozen_string_literal: true

require 'spec_helper'
require './app/models/user'

RSpec.describe 'Auth', type: :request do
  def app
    full_app
  end

  before { User.instance_variable_set(:@users, [{ id: 0, username: 'tomyyn', password: '12345678' }]) }

  describe '#login' do
    before { env 'rack.session', { 'user_id' => nil } }
    it 'Logs in successfully if credentials are corret' do
      post '/auth/login', { username: 'tomyyn', password: '12345678' }.to_json
      expect(last_response.status).to eq 200
    end

    it "Doesn't log in if credentials are wrong" do
      post '/auth/login', { username: 'tomyyn', password: '123123' }.to_json
      expect(last_response.status).to eq 401
    end

    it "Doesn't log in if user is already logged in or if either username or password is missing" do
      env 'rack.session', { 'user_id' => 0 }
      post '/auth/login', { username: 'tomyyn', password: '12345678' }.to_json
      expect(last_response.status).to eq 422
    end
  end
end
