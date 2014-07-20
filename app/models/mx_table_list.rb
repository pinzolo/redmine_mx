class MxTableList < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :database, class_name: 'MxDatabase'
  has_many :tables, class_name: 'MxTable', order: :physical_name
end
