class MxDatabase < ActiveRecord::Base
  unloadable

  has_many :data_types, class_name: 'MxDataType', foreign_key: :database_id, order: :name
end
