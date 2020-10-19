# frozen_string_literal: true

require 'nokogiri'

BLOCK_TITLE = 'Unauthorized Request Blocked'
DOMAIN = 'https://alza.cz'
NAME   = 'Alza'

class AlzaParser < Parser
  def initialize
    super 
    @failed_agents_amount = 0;
  end 
  def parse_pages(category:, sub_category: '')
    category_url, sub_category_name = if sub_category.nil?
                                        [category['url'], nil]
                                      else
                                        [sub_category['url'], sub_category['title']]
                                      end
    category_name = category['title']
                                    
    page_num = 1
    products_amount = 0

    response_data = []
    loop do
      @api_client = ApiParserClient.new(new_page(category_url, page_num))
      page = @api_client.parse_page

      parsed_page = validate_page(page)
      break if parsed_page.css('div#boxes').css('div.box').empty?

      parsed_page
        .css('div#boxes')
        .css('div.box')
        .each do |product|
        title          = product
                         .css('a.browsinglink')
                         .text
                         .gsub(/[\n\t\r]+/, '')
        price_with_vat = extract_price(product
                             .css('div.price')
                             .css('.c1')
                             .text)
        price_without_vat = extract_price(product
                                          .css('div.price')
                                          .css('.c2')
                                          .text)
        tax = price_without_vat - price_with_vat
        image = product
                .css('img')
                .attr('data-src')
                .value
        url = DOMAIN + product
              .css('a.browsinglink')
              .attr('href')
              .value

        response_data << {
          eshop: NAME,
          category: category_name,
          sub_category: sub_category_name,
          title: title,
          pwv: price_with_vat,
          pwov: price_without_vat,
          tax: tax,
          image_url: image,
          url: url
        }

        products_amount += 1
      end
      page_num += 1
    end
    @log = Log.new(parser: NAME,
                   data: "pages: #{page_num}, products: #{products_amount}",
                   status: 'succeed')
    @log.save
    response_data
  rescue StandardError => e
    @log = Log.new(parser: NAME,
                   data: e.to_s,
                   status: 'failed')
    @log.save
  end

  def parse_categories
    response_data = {}
    
    @api_client = ApiParserClient.new(DOMAIN)
    page = @api_client.parse_page

    parsed_page = validate_page(page)

    parsed_page
      .css('#tpf')
      .css('li')
      .each do |list_item|
      sub_categories = {}
      category = list_item.css('div.bx')

      next if category.empty?

      category_title = category
                       .css('a')
                       .first['title']
      category_url = category
                     .css('a')
                     .first['href']

      category
        .css('div.float-block')
        .each do |category_item|
          # skip category if there are no subcategories
          next if category_item.css('div.cr').empty?

          category_item
            .css('div.cr')
            .css('.head')
            .css('a')
            .each do |sub_category_item|
              sub_category_name = sub_category_item.text
              sub_category_data = { title: sub_category_name,
                                    url: sub_category_item['href'] }
              sub_categories[sub_category_name] = sub_category_data
            end
        end
      response_data[category_title] = { title: category_title,
                                        url: category_url,
                                        sub_categories: sub_categories }
    end
    response_data
  end

  private

  def validate_page(page)
   parsed_page = Nokogiri::HTML(page)
    loop do 
      break unless parsed_page.css('title').text == BLOCK_TITLE
      @failed_agents_amount += 1
      @api_client.user_agents = @api_client.user_agents.drop(@failed_agents_amount)
      parsed_page = Nokogiri::HTML(@api_client.parse_page)
      p @api_client.user_agents.length
    end
    parsed_page
  end 

  def extract_price(string)
    string.split(/[^\d]/).join.to_i
  end

  def new_page(url, page_num)
    DOMAIN + url.gsub('.htm', '') + '-p' + page_num.to_s + '.htm'
  end
end
