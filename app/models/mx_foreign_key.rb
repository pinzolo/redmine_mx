class MxForeignKey < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :table, class_name: 'MxTable'
  has_many :relations, class_name: 'MxForeignKeyRelation', order: :position, dependent: :destroy
end
