class CreateCategoryProduct < ActiveRecord::Migration[7.0]
  def change
    # If you want to add an index for faster querying through this join:
    create_join_table :categories, :products do |t|
      t.foreign_key :categories, column: :category_id, index: true
      t.foreign_key :products, column: :product_id, index: true
      t.index %i[category_id product_id]
      t.index %i[product_id category_id]
    end
  end
end
