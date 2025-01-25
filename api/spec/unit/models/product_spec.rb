# frozen_string_literal: true

require 'spec_helper'
require './app/models/product'

RSpec.describe Product do
  describe '.create' do
    before :each do
      Product.instance_variable_set(:@products, [{ id: 0, name: 'producto', external_id: '1234' }])
    end
    context 'with correct data' do
      it 'creates a new product' do
        expect(Product.create('Product', '12345')).to eq true
      end
    end

    context 'with missing data' do
      it 'does not create a new product' do
        expect(Product.create('Product', nil)).to eq false
      end
    end

    context 'with a repeated external_id data' do
      it 'does not create a new product' do
        expect(Product.create('Product', '1234')).to eq false
      end
    end
  end

  describe '.create_async' do
    it 'enqueues the creation of a new product' do
      expect_any_instance_of(CreateProductTask).to receive(:perform_async).with(name: 'Product', external_id: '1234',
                                                                                log_id: anything)
      Product.create_async('Product', '1234')
    end

    it 'returns the log_id' do
      expect(Product.create_async('Product', '1234')).to be_a(Integer)
    end
  end

  describe '.list' do
    before :each do
      Product.instance_variable_set(:@products,
                                    [{ id: 0, name: 'Product', external_id: '1234' },
                                     { id: 1, name: 'Product', external_id: '1235' },
                                     { id: 2, name: 'Producto', external_id: '1236' }])
    end
    context 'with correct data' do
      it 'returns the list of products' do
        products, count, page_count = Product.list(0, 10, {})
        expect(products).to eq [{ id: 0, name: 'Product', external_id: '1234' },
                                { id: 1, name: 'Product', external_id: '1235' },
                                { id: 2, name: 'Producto', external_id: '1236' }]
        expect(count).to eq 3
        expect(page_count).to eq 1
      end
    end
  end

  describe '.list_creation_logs' do
    before :each do
      Product.instance_variable_set(:@creation_logs,
                                    [{ log_id: 0, name: 'Product', external_id: '1234', status: 'creating' },
                                     { log_id: 1, name: 'Product', external_id: '1235', status: 'creating' },
                                     { log_id: 2, name: 'Producto', external_id: '1236', status: 'creating' }])
    end

    context 'with correct data' do
      it 'returns the list of creation logs' do
        creation_logs, count, page_count = Product.list_creation_logs(0, 10, {})
        expect(creation_logs).to eq [{ log_id: 0, name: 'Product', external_id: '1234', status: 'creating' },
                                     { log_id: 1, name: 'Product', external_id: '1235', status: 'creating' },
                                     { log_id: 2, name: 'Producto', external_id: '1236', status: 'creating' }]
        expect(count).to eq 3
        expect(page_count).to eq 1
      end
    end
  end
end
