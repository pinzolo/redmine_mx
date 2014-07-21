class MxColumn < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :table, class_name: 'MxTable'
  belongs_to :data_type, class_name: 'MxDataType'
end
