class MxIndex < ActiveRecord::Base
  unloadable

  belongs_to :table, class_name: 'MxTable'
  has_many :columns_rels, class_name: 'MxIndexColumn', foreign_key: :index_id, order: :position, dependent: :destroy
  has_many :columns, through: :columns_rels
end
