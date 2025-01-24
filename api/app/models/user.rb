# frozen_string_literal: true

# Modelo para usuarios.
class User
  @users = [{ id: 0, username: 'tomyyn', password: '12345678' }]

  attr_reader :id, :username, :password

  def initialize(id, username, password)
    @id = id
    @username = username
    @password = password
  end

  def self.find_by(**args)
    user = @users.find { |usr| args.all? { |key, value| usr[key] == value } }
    return nil if user.nil?

    new(user[:id], user[:username], user[:password])
  end
end
