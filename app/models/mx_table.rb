class MxTable < ActiveRecord::Base
  unloadable

  belongs_to :project
  has_many :columns, class_name: 'MxColumn', foreign_key: :table_id, order: :position
  has_many :indices, class_name: 'MxIndex', foreign_key: :table_id, order: :name
end
