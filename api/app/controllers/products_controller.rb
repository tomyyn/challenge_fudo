# frozen_string_literal: true

require_relative 'base_controller'
require_relative '../models/product'

# Controlador para el manejo de productos.
class ProductsController < BaseController
  private

  def route_request
    case routing_info
    when ['POST', '/']
      create
    when ['GET', '/']
      index
    when ['GET', '/creation_logs']
      creation_logs_index
    else
      not_found
    end
  end

  def create
    if params[:name].nil? || params[:external_id].nil?
      return [422, {},
              [{ 'error' => 'name and external_id are required' }]]
    end

    log_id = Product.create_async(params[:name], params[:external_id], params[:webhook_url])
    [202, {}, [{ 'log_id' => log_id }]]
  end

  def index
    products, count, page_count = Product.list(params[:page].to_i, (params[:per_page]&.to_i || 10),
                                               params.except(:page, :per_page))
    [200, {}, [{ products: products, count: count, page_count: page_count }]]
  end

  def creation_logs_index
    creation_logs, count, page_count = Product.list_creation_logs(params[:page].to_i, (params[:per_page]&.to_i || 10),
                                                                  params.except(:page, :per_page))
    [200, {}, [{ creation_logs: creation_logs, count: count, page_count: page_count }]]
  end
end
