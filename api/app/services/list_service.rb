# frozen_string_literal: true

# Servicio para la generación de listas.
class ListService
  def initialize(list, page = 0, per_page = 10, filters = {})
    @list = list
    @page = page
    @per_page = per_page
    @filters = filters
  end

  def filter_and_paginate_list
    @list = filter_list
    paginate_list
  end

  def filter_list
    if @filters.any?
      @list = @list.select do |item|
        @filters.all? do |key, value|
          item[key].to_s == value.to_s
        end
      end
    end

    @list
  end

  def paginate_list
    page_count = (@list.size / @per_page.to_f).ceil
    count = @list.size

    @list = @list.slice(@page * @per_page, @per_page) || []

    [@list, count, page_count]
  end
end
