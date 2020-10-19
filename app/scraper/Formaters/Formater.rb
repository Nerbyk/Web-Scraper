# frozen_string_literal: true

require 'json'
require 'active_support/core_ext'
class Formater
  def self.to_json(hash_data)
    hash_data.to_json
  end

  def self.to_xml(hash_data)
    hash_data.to_xml(root: 'data')
  end
end
