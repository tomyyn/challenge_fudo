# frozen_string_literal: true

require_relative 'base_task'
require_relative '../services/request_service'

# Tarea asíncrona para la creación de un producto.
class CreateProductTask < BaseTask
  def perform(name:, external_id:, log_id: nil, webhook_url: nil)
    sleep(5) unless ENV['RACK_ENV'] == 'test'
    Product.create(name, external_id, log_id)
    return if webhook_url.nil?

    log = Product.find_creation_log(log_id)
    send_webhook(log, webhook_url) unless log.nil?
  end

  def send_webhook(log, webhook_url)
    RequestService.new(webhook_url, :post, {}, log).execute
  end
end
