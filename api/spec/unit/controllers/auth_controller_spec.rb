# frozen_string_literal: true

require 'spec_helper'
require './app/controllers/auth_controller'

RSpec.describe AuthController do
  def app
    Rack::Builder.parse_file('config.ru')
  end

  describe 'POST /login' do
    context 'when user exists' do
      let!(:body) { { username: 'tomyyn', password: '12345678' }.to_json }
      it 'returns 200' do
        post '/auth/login', body
        expect(last_response.status).to eq 200
      end
    end
  end
end
