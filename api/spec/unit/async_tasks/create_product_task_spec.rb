# frozen_string_literal: true

require 'spec_helper'
require './app/async_tasks/create_product_task'
require './app/models/product'

RSpec.describe CreateProductTask do
  describe '#perform' do
    it 'creates a new product' do
      expect(Product).to receive(:create).with('Product', '1234', 1)
      task = CreateProductTask.new
      task.perform(name: 'Product', external_id: '1234', log_id: 1)
    end

    it 'does not send the webhook if the url is not provided' do
      User.instance_variable_set(:@creation_logs, [{ log_id: 1 }])
      expect(RequestService).not_to receive(:new)
      task = CreateProductTask.new
      task.perform(name: 'Product', external_id: '1234', log_id: 1)
    end

    context 'when webhook_url is provided' do
      it 'sends the webhook' do
        allow(Product).to receive(:create).and_return(true)
        allow(Product).to receive(:find_creation_log).with(1).and_return({ log_id: 1, status: 'created' })
        expect_any_instance_of(RequestService).to receive(:execute)
        task = CreateProductTask.new
        task.perform(name: 'Product', external_id: '1234', log_id: 1, webhook_url: 'http://example.com')
      end
    end
  end
end
