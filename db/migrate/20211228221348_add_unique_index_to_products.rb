class AddUniqueIndexToProducts < ActiveRecord::Migration[7.1]
  def change
    add_index :products, :url, unique: true, name: 'unique_index_products_on_url'
  end
end
