# frozen_string_literal: true

require 'spec_helper'
require './app/models/user'

RSpec.describe 'Product', type: :request, openapi: { tags: ['Products'], security: [{ 'CookieAuth' => [] }] } do
  def app
    full_app
  end

  before { User.instance_variable_set(:@users, [{ id: 0, username: 'tomyyn', password: '12345678' }]) }

  describe '#create', openapi: {
    summary: 'Create a new product',
    description: 'Starts the aynchronous creation of a new product and returns the log_id of the creation process. If provided with a webhook_url, it will notify the result of the operation.'
  } do
    it 'Enqueues the creation of a new product' do
      env 'rack.session', { 'user_id' => 0 }
      post '/products', { name: 'Product', external_id: '1234', webhook_url: 'http://www.example.com/' }.to_json
      expect(last_response.status).to eq 202
      expect(last_response.body).to match_response_schema('shared', 'asyncCreationResponse')
    end

    it 'Fails if the user is not logged in', openapi: { description: 'Returns a 401 error if unauthorized.' } do
      env 'rack.session', { 'user_id' => nil }
      post '/products', { name: 'Product', external_id: '1234', webhook_url: 'http://www.example.com/' }.to_json
      expect(last_response.status).to eq 401
      expect(last_response.body).to match_response_schema('shared', 'error')
    end

    it 'Does not enqueue the creation of a new product if data is missing',
       openapi: { description: 'Does not enqueue the creation of a new product if either name or external_id is missing.' } do
      env 'rack.session', { 'user_id' => 0 }
      post '/products', { name: 'Product', external_id: nil }.to_json
      expect(last_response.status).to eq 422
      expect(last_response.body).to match_response_schema('shared', 'error')
    end
  end

  describe '#list', openapi: {
    summary: 'List products',
    description: 'Returns a list of products that match the provided pagination and filters.'
  } do
    before { Product.instance_variable_set(:@products, [{ id: 0, name: 'Product', external_id: '1234' }]) }

    it 'Returns the list of products' do
      env 'rack.session', { 'user_id' => 0 }
      get '/products', { page: 0, per_page: 10, id: 0, name: 'Product', external_id: '1234' }
      expect(last_response.status).to eq 200
      expect(last_response.body).to match_response_schema('products', 'listProductsResponse')
      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body['products'].size).to eq 1
    end

    it 'Fails if the user is not logged in', openapi: { description: 'Returns a 401 error if unauthorized.' } do
      env 'rack.session', { 'user_id' => nil }
      get '/products'
      expect(last_response.status).to eq 401
      expect(last_response.body).to match_response_schema('shared', 'error')
    end
  end

  describe '#list_creation_logs', openapi: {
    summary: 'List creation logs',
    description: 'Returns a list of product creation logs that match the provided pagination and filters.'
  } do
    before do
      User.instance_variable_set(:@creation_logs,
                                 [{ log_id: 0, product_id: 0, status: 'failed', errors: ['Invalid value'] }])
    end

    it 'Returns the list of creation logs' do
      env 'rack.session', { 'user_id' => 0 }
      get '/products/creation_logs', { page: 0, per_page: 10, log_id: 0 }
      expect(last_response.status).to eq 200
      expect(last_response.body).to match_response_schema('products', 'listCreationLogsResponse')
      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body['creation_logs'].size).to eq 1
    end

    it 'Fails if the user is not logged in', openapi: { description: 'Returns a 401 error if unauthorized.' } do
      env 'rack.session', { 'user_id' => nil }
      get '/products/creation_logs'
      expect(last_response.status).to eq 401
      expect(last_response.body).to match_response_schema('shared', 'error')
    end
  end
end
