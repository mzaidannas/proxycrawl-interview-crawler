class CreateCategory < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :title
      t.integer :parent_id
      t.timestamps

      t.index :title, unique: true
      t.foreign_key :categories, column: :parent_id, index: true
    end
  end
end
