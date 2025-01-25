# frozen_string_literal: true

require 'spec_helper'
require './app/controllers/auth_controller'

RSpec.describe AuthController do
  def app
    AuthController.new
  end

  describe 'POST /login' do
    before do
      User.instance_variable_set(:@users, [{ id: 0, username: 'tomyyn', password: '12345678' }])
    end
    context 'when user exists' do
      let!(:body) { { username: 'tomyyn', password: '12345678' }.to_json }
      before :each do
        env 'rack.session', { 'user_id' => nil }
      end
      it 'returns 200' do
        post '/login', body
        expect(last_response.status).to eq 200
      end

      it "sets the user's id in the session" do
        post '/login', body
        expect(last_request.session['user_id']).to eq 0
      end
    end

    context 'when user does not exist' do
      let!(:body) { { username: 'Faker', password: 'FakePassword' }.to_json }
      before :each do
        env 'rack.session', { 'user_id' => nil }
      end
      it 'returns 401' do
        post '/login', body
        expect(last_response.status).to eq 401
      end

      it "doesn't set the user's id in the session" do
        post '/login', body
        expect(last_request.session['user_id']).to eq nil
      end
    end

    context 'when user is already logged in' do
      let!(:body) { { username: 'anuser', password: 'apassword' }.to_json }
      before :each do
        env 'rack.session', { 'user_id' => 0 }
      end

      it 'returns 422' do
        post '/login', body
        expect(last_response.status).to eq 422
      end

      it "doesn't modify the user's id in the session" do
        post '/login', body
        expect(last_request.session['user_id']).to eq 0
      end
    end
  end
end
