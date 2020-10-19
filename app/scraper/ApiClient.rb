# frozen_string_literal: true

require 'httparty'

class ApiParserClient
  attr_accessor :user_agents
  def initialize(url)
    @url         = url
    @user_agents = File.foreach('./app/scraper/user-agents.txt').map { |line| line.gsub(/\n/, '') }
  end

  def parse_page
    headers = { 'User-Agent': @user_agents.first }
    page = HTTParty.get(url, headers: headers)

    page
  end

  private

  attr_reader :url
end
