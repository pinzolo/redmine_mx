class MxForeignKeyRelation < ActiveRecord::Base
  unloadable

  belongs_to :source_column, class_name: 'MxColumn'
  belongs_to :referred_column, class_name: 'MxColumn'
end
