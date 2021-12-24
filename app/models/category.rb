class Category < ApplicationRecord
  include HierarchicalModel

  has_and_belongs_to_many :products
end
