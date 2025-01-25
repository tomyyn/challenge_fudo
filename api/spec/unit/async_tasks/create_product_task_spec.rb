# frozen_string_literal: true

require 'spec_helper'
require './app/async_tasks/create_product_task'

RSpec.describe CreateProductTask do
  describe '#perform' do
    it 'creates a new product' do
      expect(Product).to receive(:create).with('Product', '1234', 1)
      task = CreateProductTask.new
      task.perform(name: 'Product', external_id: '1234', log_id: 1)
    end
  end
end
