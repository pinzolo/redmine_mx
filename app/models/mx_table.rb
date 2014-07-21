class MxTable < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :project
  has_many :columns, class_name: 'MxColumn', foreign_key: :table_id, order: :position, dependent: :destroy
  has_many :indices, class_name: 'MxIndex', foreign_key: :table_id, order: :name, dependent: :destroy
  has_many :foreign_keys, class_name: 'MxForeignKey', foreign_key: :table_id, dependent: :destroy
  has_many :taggings, as: :mx_taggable
  has_many :tags, through: :taggins
  has_many :versions, class_name: 'MxTableVersion', foreign_key: :table_id, dependent: :destroy
end
