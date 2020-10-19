# frozen_string_literal: true

class CreateEshopProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :eshop_products do |t|
      t.string :eshop
      t.string :category
      t.string :sub_category
      t.string :title
      t.integer :price_with_vat
      t.integer :price_without_vat
      t.integer :tax
      t.string :image_url
      t.string :url

      t.timestamps
    end
  end
end
