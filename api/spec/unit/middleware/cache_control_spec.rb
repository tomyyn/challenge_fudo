# frozen_string_literal: true

require 'spec_helper'
require './app/middleware/cache_control'

RSpec.describe CacheControl do
  def app
    Rack::Builder.new do
      use CacheControl
      run ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
    end
  end

  context "when the request is to '/open_api.yaml'" do
    it "sets the cache control header to 'no-store'" do
      get '/openapi.yaml'
      expect(last_response.headers['Cache-Control']).to eq 'no-store'
    end
  end

  context "when the request is to '/AUTHORS'" do
    it "sets the cache control header to 'public, max-age=86400'" do
      get '/AUTHORS'
      expect(last_response.headers['Cache-Control']).to eq 'public, max-age=86400'
    end
  end

  context "when the request is to '/other'" do
    it 'does not set the cache control header' do
      get '/other'
      expect(last_response.headers['Cache-Control']).to eq nil
    end
  end
end
