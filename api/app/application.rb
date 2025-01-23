# frozen_string_literal: true

# Clase principal para el manejo de la aplicación.
class Application
  def call(env)
    counter = env['rack.session']['counter'] || 0
    counter += 1
    env['rack.session']['counter'] = counter
    [200, {}, ["Hello, worlds! #{counter}"]]
  end
end
