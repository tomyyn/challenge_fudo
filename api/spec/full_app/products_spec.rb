# frozen_string_literal: true

require 'spec_helper'
require './app/models/user'

RSpec.describe 'Product', type: :request do
  def app
    full_app
  end

  before { User.instance_variable_set(:@users, [{ id: 0, username: 'tomyyn', password: '12345678' }]) }

  describe '#create' do
    it 'Enqueues the creation of a new product' do
      env 'rack.session', { 'user_id' => 0 }
      post '/products', { name: 'Product', external_id: '1234', webhook_url: 'http://www.example.com/' }.to_json
      expect(last_response.status).to eq 202
    end

    it 'Fails if the user is not logged in' do
      env 'rack.session', { 'user_id' => nil }
      post '/products', { name: 'Product', external_id: '1234', webhook_url: 'http://www.example.com/' }.to_json
      expect(last_response.status).to eq 401
    end

    it 'Does not enqueue the creation of a new product if data is missing' do
      env 'rack.session', { 'user_id' => 0 }
      post '/products', { name: 'Product', external_id: nil }.to_json
      expect(last_response.status).to eq 422
    end
  end

  describe '#list' do
    before { Product.instance_variable_set(:@products, [{ id: 0, name: 'Product', external_id: '1234' }]) }

    it 'Returns the list of products' do
      env 'rack.session', { 'user_id' => 0 }
      get '/products'
      expect(last_response.status).to eq 200
      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body['products'].size).to eq 1
    end

    it 'Fails if the user is not logged in' do
      env 'rack.session', { 'user_id' => nil }
      get '/products'
      expect(last_response.status).to eq 401
    end
  end

  describe '#list_creation_logs' do
    before do
      User.instance_variable_set(:@creation_logs,
                                 [{ log_id: 0, product_id: 0, status: 'failed', errors: ['Invalid value'] }])
    end

    it 'Returns the list of creation logs' do
      env 'rack.session', { 'user_id' => 0 }
      get '/products/creation_logs'
      expect(last_response.status).to eq 200
      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body['creation_logs'].size).to eq 1
    end

    it 'Fails if the user is not logged in' do
      env 'rack.session', { 'user_id' => nil }
      get '/products/creation_logs'
      expect(last_response.status).to eq 401
    end
  end
end
