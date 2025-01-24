# frozen_string_literal: true

# Extensión de la clase Hash para transformar las claves de un hash anidado.
class Hash
  def deep_transform_keys(&block)
    each_with_object({}) do |(key, value), result|
      transformed_key = block.call(key)
      transformed_value = if value.is_a?(Hash)
                            value.deep_transform_keys(&block)
                          elsif value.is_a?(Array)
                            value.map { |v| v.is_a?(Hash) ? v.deep_transform_keys(&block) : v }
                          else
                            value
                          end
      result[transformed_key] = transformed_value
    end
  end
end
