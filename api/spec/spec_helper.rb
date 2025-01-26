# frozen_string_literal: true

require 'rspec'
require 'rack'
require 'rack/test'
require 'json'
require 'json-schema'
require 'byebug'
require 'rspec/openapi'

ENV['RACK_ENV'] = 'test'

SCHEMAS_ROOT = "#{Dir.pwd}/spec/support/api/schemas".freeze

Dir[File.expand_path('../lib/**/*.rb', __dir__)].each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include Rack::Test::Methods

  RSpec::OpenAPI.title = 'API Challenge FUDO'
  RSpec::OpenAPI.application_version = '1.0.0'
  RSpec::OpenAPI.path = 'public/openapi.yaml'
  RSpec::OpenAPI.servers = [{ url: 'http://localhost:9292' }]

  RSpec::OpenAPI.security_schemes = {
    'cookieAuth' => {
      name: 'rack.session',
      in: 'cookie',
      type: 'apiKey'
    }
  }
end

RSpec::Matchers.define :match_response_schema do |directory, schema|
  match do |_response|
    schema_dir = "#{SCHEMAS_ROOT}/#{directory}"
    schema_file = "#{schema_dir}/#{schema}.json"
    JSON::Validator.validate!(schema_file, last_response.body)
  end
end

def full_app
  Rack::Builder.parse_file('config.ru')
end
