# frozen_string_literal: true

class Parser
  attr_accessor :log
  def initialize
    @log = ''
  end

  def parse_pages(category:, sub_category: nil)
    raise NotImplementedError, "#{self.class} has not implemeted method '#{__method__}'"
  end

  def parse_categories
    raise NotImplementedError, "#{self.class} has not implemeted method '#{__method__}'"
  end
end
