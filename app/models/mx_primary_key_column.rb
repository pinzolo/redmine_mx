class MxPrimaryKeyColumn < ActiveRecord::Base
  unloadable

  belongs_to :column, class_name: 'MxColumn'
end