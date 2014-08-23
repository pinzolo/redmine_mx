class MxForeignKeyRelation < ActiveRecord::Base
  unloadable

  belongs_to :column, class_name: 'MxColumn'
  belongs_to :ref_column, class_name: 'MxColumn'
end
