# frozen_string_literal: true

require_relative 'base_controller'
require_relative '../models/product'

# Controlador para el manejo de productos.
class ProductsController < BaseController
  private

  def route_request
    case routing_info
    when ['POST', '']
      create
    when ['GET', '']
      index
    else
      not_found
    end
  end

  def create
    if params[:name].nil? || params[:external_id].nil?
      return [422, {},
              [{ 'error' => 'name and external_id are required' }]]
    end

    log_id = Product.create_async(params[:name], params[:external_id])
    [202, {}, [{ 'log_id' => log_id }]]
  end

  def index; end
end
