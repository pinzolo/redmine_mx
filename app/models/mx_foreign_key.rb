class MxForeignKey < ActiveRecord::Base
  unloadable

  belongs_to :table, class_name: 'MxTable'
  has_many :relations, class_name: 'MxForeignKeyRelation', dependent: :destroy
end
