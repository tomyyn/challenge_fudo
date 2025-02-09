# frozen_string_literal: true

require_relative '../async_tasks/create_product_task'
require_relative '../services/list_service'

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

  def self.create(name, external_id, log_id = nil)
    errors = []
    id = nil
    errors << 'Name is required' if name.nil? || name.empty?
    errors << 'External ID is required' if external_id.nil? || external_id.empty?

    @creation_mutex.synchronize do
      errors << 'External ID already exists' if @products.any? { |product| product[:external_id] == external_id }
      if errors.empty?
        id = @id
        @id += 1
        @products << { id: id, name: name, external_id: external_id }
      end
    end

    update_creation_log(log_id, errors) unless log_id.nil?

    errors.empty?
  end

  def self.create_async(name, external_id, webhook_url = nil)
    task = CreateProductTask.new
    task_id = task.id
    task.perform_async(name: name, external_id: external_id, log_id: task_id, webhook_url: webhook_url)
    @creation_logs << { log_id: task_id, name: name, external_id: external_id, status: 'creating' }
    task_id
  end

  def self.update_creation_log(log_id, errors)
    log = find_creation_log(log_id)
    return if log.nil?

    log[:status] = errors.empty? ? 'created' : 'failed_to_create'
    log[:errors] = errors
  end

  def self.list(page, per_page, filters = {})
    filters = filters.slice(:id, :name, :external_id)
    ListService.new(@products, page, per_page, filters).filter_and_paginate_list
  end

  def self.list_creation_logs(page, per_page, filters = {})
    filters = filters.slice(:log_id)
    ListService.new(@creation_logs, page, per_page, filters).filter_and_paginate_list
  end

  def self.find_creation_log(log_id)
    @creation_logs.find { |log_hash| log_hash[:log_id] == log_id }
  end
end
