# frozen_string_literal: true

require_relative '../async_tasks/create_product_task'

# Modelo para productos.
class Product
  @products = []
  @id = 0
  @creation_logs = []
  @creation_mutex = Mutex.new

  attr_reader :id, :username, :password

  def initialize(id, name, external_id)
    @id = id
    @name = name
    @external_id = external_id
  end

  def self.create(name, external_id, log_id)
    errors = []
    id = nil
    errors << 'Name is required' if name.nil? || name.empty?
    errors << 'External ID is required' if external_id.nil? || external_id.empty?

    @creation_mutex.synchronize do
      errors << 'External ID already exists' if @products.any? { |product| product[:external_id] == external_id }
      if errors.empty?
        id = @id
        @id += 1
      end
    end

    @products << { id: id, name: name, external_id: external_id } if errors.empty?

    update_creation_log(log_id, errors) unless log_id.nil?

    errors.empty?
  end

  def self.create_async(name, external_id)
    task = CreateProductTask.new
    task_id = task.id
    task.perform_async(name: name, external_id: external_id, log_id: task_id)
    @creation_logs << { log_id: task_id, name: name, external_id: external_id, status: 'creating' }
    task_id
  end

  def self.update_creation_log(log_id, errors)
    log = @creation_logs.find { |log_hash| log_hash[:log_id] == log_id }
    log[:status] = errors.empty? ? 'created' : 'failed_to_create'
    log[:errors] = errors
  end

  def self.list(page, per_page, filters = {})
    filters = filters.slice(:id, :name, :external_id)

    products = @products
    if filters.any?
      products = products.select do |product|
        filters.all? do |key, value|
          product[key].to_s == value.to_s
        end
      end
    end

    page_count = (products.size / per_page.to_f).ceil
    count = products.size

    products = products.slice(page * per_page, per_page) || []

    [products, count, page_count]
  end
end
