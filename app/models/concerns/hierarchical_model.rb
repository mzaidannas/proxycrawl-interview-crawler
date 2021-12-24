# frozen_string_literal: true

module HierarchicalModel
  extend ActiveSupport::Concern

  included do
    belongs_to :parent, foreign_key: hierarchical_foreign_key, class_name: name, touch: true, inverse_of: :children, optional: true
    has_many :children, foreign_key: hierarchical_foreign_key, class_name: name, dependent: :destroy,
                        inverse_of: :parent
    accepts_nested_attributes_for :children,
                                  allow_destroy: true

    alias_attribute :parent_id, hierarchical_foreign_key if hierarchical_foreign_key != :parent_id
  end

  class_methods do
    def hierarchical_foreign_key
      :parent_id
    end
  end

  # TODO: Optimise recursive query
  def ancestors
    return [] if parent_id.blank?
    sql = <<-SQL.squish
      (WITH RECURSIVE parents AS (
        SELECT
          *
        FROM
          #{self.class.table_name}
        WHERE
          id = #{parent_id}
        UNION
          SELECT
            c.*
          FROM
            #{self.class.table_name} c
          INNER JOIN parents p ON p.parent_id = c.id
      ) SELECT
        *
      FROM
      parents) #{self.class.table_name};
    SQL

    self.class.from(sql).all.to_a
  end

  def ancestors_and_self
    ancestors + [self]
  end

  def self_and_descendants
    [self] + descendants
  end

  def descendants
    sql = <<-SQL.squish
      (WITH RECURSIVE children AS (
        SELECT *
        FROM #{self.class.table_name}
        WHERE parent_id = #{id}
        UNION
        SELECT p.*
        FROM #{self.class.table_name} p
        INNER JOIN children c ON c.id = p.parent_id
      ) SELECT
        *
      FROM
        children) #{self.class.table_name};
    SQL

    self.class.from(sql).all.distinct.to_a
  end
end
