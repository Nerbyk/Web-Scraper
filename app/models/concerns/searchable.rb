# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings do
      mappings dynamic: false do
        indexes :eshop, type: :text
        indexes :category, type: :text
        indexes :sub_category, type: :text
        indexes :title, type: :text
        indexes :price_with_vat, type: :integer
        indexes :price_without_vat, type: :integer
        indexes :tax, type: :integer
        indexes :image_url, type: :text
        indexes :url, type: :text
      end
    end
  end

  def self.search(query: '', fields: ['title'], page: 1, size: 15)

    @search_definition = if query.empty?
                           {
                             query: {
                               match_all: {

                               }
                             },
                             size: 15,
                             from: page
                           }
                         else
                           {
                             query: {
                               multi_match: {
                                 query: query,
                                 fields: fields
                               }
                             },
                             size: 15,
                             from: page
                           }
                         end
    EshopProduct.__elasticsearch__.search(@search_definition)
  end

  class_methods do
    def settings_attributes
      { index: {
        analysis: {
          analyzer: {
            autocomplete: {
              type: :custom,
              tokenizer: :standard,
              filter: %i[lowercase autocomplete]
            }
          },
          filter: {
            autocomplete: {
              type: :edge_ngram,
              min_gram: 2,
              max_gram: 25
            }
          }
        }
      } }
    end
  end
end
