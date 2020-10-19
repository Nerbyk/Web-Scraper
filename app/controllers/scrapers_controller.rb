# frozen_string_literal: true

class ScrapersController < ApplicationController
  include ActiveModel::Validations
  before_action :get_scraper, only: %i[categories parse]
  before_action :validate_params, only: %i[categories parse]

  attr_reader :data_format

  def categories
    if @scraper
      render_data(data: { categories: Formater.to_json(@scraper.parser.parse_categories) }, status: :ok)
    else
      render_data(status: :bad_request)
    end
  end

  def parse
    category = category_params
    sub_category = sub_category_params

    scraped_data = @scraper.parser.parse_pages(category: category, sub_category: sub_category)
    save_data(scraped_data)

    if @scraper
      render_data(data: {

                    log: Formater.to_json(@scraper.parser.log)
                  }, status: :ok)
    else
      render_data(data: {

                    log: Formater.to_json(@scraper.parser.log)
                  }, status: :bad_request)
    end
  end

  def search
    @data_format = get_data_format
    result = Searchable.search(query: params[:sub_string],
                               page: params[:page]).results

    render_data(data: { result: result },
                status: :ok)
  end

  private

  def render_data(data: '', status:)
    case data_format
    when 'json'
      render json: Formater.to_json(data), status: status
    when 'xml'
      render xml: Formater.to_xml(data), status: status
    else
      raise 'Undefined Data Type'
    end
  end

  def scraper_initializer(type, name, data_format)
    "#{type}Scraper".classify.constantize.new(name: name, data_format: data_format)
  rescue NameError
    false
  end

  def get_scraper
    type         = params['type'].capitalize
    name         = params['name']
    @data_format = get_data_format
    @scraper     = scraper_initializer(type, name, data_format)
  end

  def get_data_format
    params['data_format'].downcase
  end

  def category_params
    params.require(:category).permit(:title, :url)
  end

  def sub_category_params
    params['sub_category'].empty? ? nil : params.require(:sub_category).permit(:title, :url)
  end

  def save_data(scraped_data)
    scraped_data.each do |data|
      model = EshopProduct.find_or_initialize_by(
        eshop: data[:name],
        category: data[:category],
        sub_category: data[:sub_category],
        title: data[:title]
      )
      model.price_with_vat = data[:pwt]
      model.price_without_vat = data[:pwov]
      model.tax = data[:tax]
      model.image_url = data[:image_url]
      model.url = data[:url]
      model.save
    end
  end

  def validate_params 
    return false unless params['type'].present? && params['name'].present? && params['data_format'].present? 
    params_include?(:type, %w(eshops)) 
    params_include?(:name, %w(Alza))
    params_include?(:data_type, %w(JSON XML))
  end 

  def params_include?(key, values)
    !params.key?(key) || values.include?(params[key])
  end
end
