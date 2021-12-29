# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_28_221348) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.integer "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["title"], name: "index_categories_on_title", unique: true
  end

  create_table "categories_products", id: false, force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "product_id", null: false
    t.index ["category_id", "product_id"], name: "index_categories_products_on_category_id_and_product_id"
    t.index ["product_id", "category_id"], name: "index_categories_products_on_product_id_and_category_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.float "rating"
    t.integer "reviews"
    t.float "discount_price"
    t.float "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_products_on_created_at", using: :brin
    t.index ["discount_price"], name: "index_products_on_discount_price"
    t.index ["price"], name: "index_products_on_price"
    t.index ["rating"], name: "index_products_on_rating"
    t.index ["reviews"], name: "index_products_on_reviews"
    t.index ["title"], name: "index_products_on_title", opclass: :gin_trgm_ops, using: :gin
    t.index ["updated_at"], name: "index_products_on_updated_at", using: :brin
    t.index ["url"], name: "index_products_on_url", using: :hash
    t.index ["url"], name: "unique_index_products_on_url", unique: true
  end

  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "categories_products", "categories"
  add_foreign_key "categories_products", "products"
end
