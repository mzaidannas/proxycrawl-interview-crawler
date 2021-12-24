class CreateProduct < ActiveRecord::Migration[7.0]
  def change
    enable_extension :pg_trgm
    create_table :products do |t|
      t.string :title
      t.string :url
      t.float :rating
      t.integer :reviews
      t.float :discount_price
      t.float :price
      t.timestamps

      t.index :title, using: :gin, opclass: :gin_trgm_ops
      t.index :url, using: :hash
      t.index :rating
      t.index :reviews
      t.index :discount_price
      t.index :price
      t.index :created_at, using: :brin
      t.index :updated_at, using: :brin
    end
  end
end
