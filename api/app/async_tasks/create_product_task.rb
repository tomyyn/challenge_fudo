# frozen_string_literal: true

require_relative 'base_task'

# Tarea asíncrona para la creación de un producto.
class CreateProductTask < BaseTask
  def perform(name:, external_id:, log_id: nil)
    sleep(5)
    Product.create(name, external_id, log_id)
  end
end
