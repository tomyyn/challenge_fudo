# frozen_string_literal: true

require 'spec_helper'
require './app/controllers/products_controller'

RSpec.describe ProductsController do
  def app
    ProductsController.new
  end

  describe 'POST /' do
    context 'with correct data' do
      let!(:body) { { name: 'Product', external_id: '1234' }.to_json }

      it 'returns 202' do
        post '/', body
        expect(last_response.status).to eq 202
      end

      it 'enqueues the creation of a new product' do
        expect_any_instance_of(CreateProductTask).to receive(:perform_async).with(name: 'Product', external_id: '1234',
                                                                                  log_id: anything)
        post '/', body
      end
    end

    context 'with missing data' do
      let!(:body) { { name: 'Product', external_id: nil }.to_json }

      it 'returns 422' do
        post '/', body
        expect(last_response.status).to eq 422
      end

      it "doesn't enqueue the creation of a new product" do
        expect(CreateProductTask).not_to receive(:new)
        post '/', body
      end
    end
  end

  describe 'GET /' do
    context 'with correct data' do
      let!(:params) { {} }

      before do
        Product.create('Product', '1234')
        Product.create('Product', '1235')
        Product.create('Producto', '1236')
      end

      it 'returns 200' do
        get '/', params
        expect(last_response.status).to eq 200
      end

      it 'returns the list of products' do
        get '/', params
        parsed_body = JSON.parse(last_response.body)
        expect(parsed_body.first['products'].size).to eq 3
        expect(parsed_body.first['page_count']).to eq 1
        expect(parsed_body.first['count']).to eq 3
      end

      describe 'filtering' do
        context 'by name' do
          let!(:params) { { name: 'Product' } }

          it 'returns only the products that match the filter' do
            get '/', params
            parsed_body = JSON.parse(last_response.body)
            expect(parsed_body.first['products'].size).to eq 2
            expect(parsed_body.first['page_count']).to eq 1
            expect(parsed_body.first['count']).to eq 2
            expect(parsed_body.first['products'].map { |product| product['name'] }).to eq %w[Product Product]
          end
        end

        context 'by external_id' do
          let!(:params) { { external_id: '1236' } }

          it 'returns only the products that match the filter' do
            get '/', params
            parsed_body = JSON.parse(last_response.body)
            expect(parsed_body.first['products'].size).to eq 1
            expect(parsed_body.first['page_count']).to eq 1
            expect(parsed_body.first['count']).to eq 1
            expect(parsed_body.first['products'].map { |product| product['external_id'] }).to eq ['1236']
          end
        end

        context 'by id' do
          let!(:params) { { id: 0 } }

          it 'returns only the products that match the filter' do
            get '/', params
            parsed_body = JSON.parse(last_response.body)
            expect(parsed_body.first['products'].size).to eq 1
            expect(parsed_body.first['page_count']).to eq 1
            expect(parsed_body.first['count']).to eq 1
            expect(parsed_body.first['products'].map { |product| product['id'] }).to eq [0]
          end
        end
      end

      describe 'pagination' do
        context 'with custom per_page' do
          let!(:params) { { page: 0, per_page: 2 } }
          it 'returns the specified number of products' do
            get '/', params
            parsed_body = JSON.parse(last_response.body)
            expect(parsed_body.first['products'].size).to eq 2
            expect(parsed_body.first['count']).to eq 3
            expect(parsed_body.first['page_count']).to eq 2
            expect(parsed_body.first['products'].map { |product| product['external_id'] }).to eq %w[1234 1235]
          end
        end

        context 'with custom page per_page' do
          let!(:params) { { page: 1, per_page: 2 } }

          it 'returns 1 product' do
            get '/', params
            parsed_body = JSON.parse(last_response.body)
            expect(parsed_body.first['products'].size).to eq 1
            expect(parsed_body.first['count']).to eq 3
            expect(parsed_body.first['page_count']).to eq 2
            expect(parsed_body.first['products'].map { |product| product['external_id'] }).to eq ['1236']
          end
        end
      end
    end
  end

  describe 'GET /creation_logs' do
    context 'with correct data' do
      let!(:params) { {} }

      before do
        Product.instance_variable_set(:@creation_logs, [{ log_id: 4 }, { log_id: 12 }, { log_id: 21 }])
      end

      it 'returns 200' do
        get '/creation_logs', params
        expect(last_response.status).to eq 200
      end

      it 'returns the list of products' do
        get '/creation_logs', params
        parsed_body = JSON.parse(last_response.body)
        expect(parsed_body.first['creation_logs'].size).to eq 3
        expect(parsed_body.first['page_count']).to eq 1
        expect(parsed_body.first['count']).to eq 3
      end

      describe 'filtering' do
        context 'by log_id' do
          let!(:params) { { log_id: 12 } }

          it 'returns only the logs that match the filter' do
            get '/creation_logs', params
            parsed_body = JSON.parse(last_response.body)
            expect(parsed_body.first['creation_logs'].size).to eq 1
            expect(parsed_body.first['page_count']).to eq 1
            expect(parsed_body.first['count']).to eq 1
            expect(parsed_body.first['creation_logs'].map { |log| log['log_id'] }).to eq [12]
          end
        end
      end

      describe 'pagination' do
        context 'with custom per_page' do
          let!(:params) { { page: 0, per_page: 2 } }
          it 'returns the specified number of logs' do
            get '/creation_logs', params
            parsed_body = JSON.parse(last_response.body)
            expect(parsed_body.first['creation_logs'].size).to eq 2
            expect(parsed_body.first['count']).to eq 3
            expect(parsed_body.first['page_count']).to eq 2
            expect(parsed_body.first['creation_logs'].map { |log| log['log_id'] }).to eq [4, 12]
          end
        end

        context 'with custom page per_page' do
          let!(:params) { { page: 1, per_page: 2 } }

          it 'returns 1 log' do
            get '/creation_logs', params
            parsed_body = JSON.parse(last_response.body)
            expect(parsed_body.first['creation_logs'].size).to eq 1
            expect(parsed_body.first['count']).to eq 3
            expect(parsed_body.first['page_count']).to eq 2
            expect(parsed_body.first['creation_logs'].map { |log| log['log_id'] }).to eq [21]
          end
        end
      end
    end
  end
end
