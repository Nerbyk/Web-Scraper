# frozen_string_literal: true

require 'nokogiri'
require 'httparty'
require 'useragent'

class ApiParserClient
  def self.parse_page(url)
    user_agent_desktop = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '\
      'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 '\
      'Safari/537.36'
    headers = { 'User-Agent': user_agent_desktop}
    page = HTTParty.get(url, :headers => headers)
    Nokogiri::HTML(page)
  end

  private

  attr_reader :url
end
