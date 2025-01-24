# frozen_string_literal: true

require_relative 'async_tasks/create_product_task'

# Clase principal para el manejo de la aplicación.
class Application
  def call(env)
    counter = env['rack.session']['counter'] || 0

    Thread.new do
      sleep 5
      p 'ASYNC'
    end

    CreateProductTask.new.perform_async(name: 'nombre', external_id: '12123')

    counter += 1
    env['rack.session']['counter'] = counter
    [200, {}, ["Hello, worlds! #{counter}"]]
  end
end
