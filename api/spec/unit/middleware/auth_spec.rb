# frozen_string_literal: true

require 'spec_helper'
require './app/middleware/auth'
require './app/models/user'

RSpec.describe Auth do
  def app
    Rack::Builder.new do
      use Auth
      run ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
    end
  end

  before do
    User.instance_variable_set(:@users, [{ id: 0, username: 'tomyyn', password: '12345678' }])
  end

  context "when the request is to '/auth'" do
    context 'when there is no user_id in the session' do
      it 'authorizes' do
        env 'rack.session', { 'user_id' => nil }
        post '/auth'
        expect(last_response.status).to eq 200
      end
    end

    context 'when there is an existing user_id in the session' do
      it 'authorizes' do
        env 'rack.session', { 'user_id' => 0 }
        post '/auth'
        expect(last_response.status).to eq 200
      end
    end

    context 'when there is a non-existing user_id in the session' do
      it 'authorizes' do
        env 'rack.session', { 'user_id' => 1 }
        post '/auth'
        expect(last_response.status).to eq 200
      end
    end
  end

  context "when the request is not to '/auth'" do
    context 'when there is no user_id in the session' do
      it 'does not authorize' do
        env 'rack.session', { 'user_id' => nil }
        post '/other'
        expect(last_response.status).to eq 401
      end
    end

    context 'when there is an existing user_id in the session' do
      it 'authorizes' do
        env 'rack.session', { 'user_id' => 0 }
        post '/other'
        expect(last_response.status).to eq 200
      end
    end

    context 'when there is a non-existing user_id in the session' do
      it 'does not authorize' do
        env 'rack.session', { 'user_id' => 1 }
        post '/other'
        expect(last_response.status).to eq 401
      end
    end
  end
end
