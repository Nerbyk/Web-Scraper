# frozen_string_literal: true

class Scraper
  attr_reader :name, :data_format, :parser
  def initialize(name:, data_format:)
    @name        = name
    @data_format = data_format
    @parser      = parser_initializer
  end

  protected

  # Check Existence of parser
  def parser_initializer
    "#{name}Parser".classify.constantize.new
  rescue NameError
    raise NameError, "#{name}Parser class doesn't exist"
  end
end

class EshopsScraper < Scraper
end
