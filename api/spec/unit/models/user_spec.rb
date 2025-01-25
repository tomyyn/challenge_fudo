# frozen_string_literal: true

require 'spec_helper'
require './app/models/user'

RSpec.describe User do
  describe '.find_by' do
    before do
      User.instance_variable_set(:@users, [{ id: 0, username: 'tomyyn', password: '12345678' }])
    end

    context 'when user exists' do
      it 'returns the user' do
        user = User.find_by(username: 'tomyyn')
        expect(user.username).to eq 'tomyyn'
      end
    end

    context 'when user does not exist' do
      it 'returns nil' do
        user = User.find_by(username: 'Faker')
        expect(user).to eq nil
      end
    end
  end
end
