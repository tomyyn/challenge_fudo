# frozen_string_literal: true

# Extensión de la clase String para convertirla a snake_case.
class String
  def underscore
    gsub('::', '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end
end
