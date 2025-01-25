# frozen_string_literal: true

require 'spec_helper'
require './app/services/list_service'

RSpec.describe ListService do
  let!(:list) { [{ id: 1, name: 'Product' }, { id: 2, name: 'Product' }, { id: 3, name: 'Producto' }] }

  describe '#filter_list' do
    context 'with no filters' do
      it 'returns the list without changes' do
        service = ListService.new(list)
        expect(service.filter_list).to eq list
      end
    end

    context 'with one filter' do
      it 'returns the list filtered by the filters' do
        service = ListService.new(list, 0, 10, { name: 'Product' })
        expect(service.filter_list).to eq [{ id: 1, name: 'Product' }, { id: 2, name: 'Product' }]
      end
    end

    context 'with multiple filters' do
      it 'returns the list filtered by the filters' do
        service = ListService.new(list, 0, 10, { id: 1, name: 'Product' })
        expect(service.filter_list).to eq [{ id: 1, name: 'Product' }]
      end
    end
  end

  describe '#paginate_list' do
    context 'with no pagination' do
      it 'returns the list without changes' do
        service = ListService.new(list)
        expect(service.paginate_list).to eq [list, 3, 1]
      end
    end

    context 'with per_page' do
      it 'returns the list paginated' do
        service = ListService.new(list, 0, 2)
        expect(service.paginate_list).to eq [[{ id: 1, name: 'Product' }, { id: 2, name: 'Product' }], 3, 2]
      end
    end

    context 'with page and per_page' do
      it 'returns the list paginated' do
        service = ListService.new(list, 1, 1)
        expect(service.paginate_list).to eq [[{ id: 2, name: 'Product' }], 3, 3]
      end
    end
  end

  describe '#filter_and_paginate_list' do
    it 'returns the list filtered and paginated' do
      service = ListService.new(list, 1, 1, { name: 'Product' })
      expect(service.filter_and_paginate_list).to eq [[{ id: 2, name: 'Product' }], 2, 2]
    end
  end
end
