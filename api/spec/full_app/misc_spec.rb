# frozen_string_literal: true

require 'spec_helper'
require './app/models/user'
require './app/models/product'

RSpec.describe 'Misc API tests', type: :request, openapi: false do
  def app
    full_app
  end

  before do
    User.instance_variable_set(:@users, [{ id: 0, username: 'tomyyn', password: '12345678' }])
    Product.instance_variable_set(:@products, [{ id: 0, name: 'Product', external_id: '1234' }])
    env 'rack.session', { 'user_id' => 0 }
  end

  describe 'Not found route' do
    it 'returns a 404 error' do
      get '/unknown'
      expect(last_response.status).to eq 404
    end
  end

  describe 'GZIP encoding' do
    it 'returns a gzipped response when specified' do
      get '/products', {}, { 'HTTP_ACCEPT_ENCODING' => 'gzip' }
      expect(last_response.headers['Content-Encoding']).to eq 'gzip'
    end

    it 'returns a plain response when not specified' do
      get '/products'
      expect(last_response.headers['Content-Encoding']).to be_nil
    end
  end

  describe 'Static files' do
    describe 'GET /AUTHORS' do
      it 'returns the AUTHORS file' do
        get '/AUTHORS'
        expect(last_response.status).to eq 200
        expect(last_response.body).to eq File.read('./public/AUTHORS')
      end

      it 'returns the desired cache control policy' do
        get '/AUTHORS'
        expect(last_response.headers['Cache-Control']).to eq 'public, max-age=86400'
      end
    end

    describe 'GET /openapi.yaml' do
      it 'returns the OpenAPI file' do
        get '/openapi.yaml'
        expect(last_response.status).to eq 200
        expect(last_response.body).to eq File.read('./public/openapi.yaml')
      end

      it 'returns the desired cache control policy' do
        get '/openapi.yaml'
        expect(last_response.headers['Cache-Control']).to eq 'no-store'
      end
    end
  end
end
