# frozen_string_literal: true

# Clase principal para el manejo de la aplicación.
class Application
  def call(_env)
    [200, {}, ['Hello, worlds!']]
  end
end
