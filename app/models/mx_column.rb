class MxColumn < ActiveRecord::Base
  unloadable

  belongs_to :table, class_name: 'MxTable'
  belongs_to :data_type, class_name: 'MxDataType'
end
