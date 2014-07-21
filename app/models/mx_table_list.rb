class MxTableList < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :project
  belongs_to :database, class_name: 'MxDatabase'
  has_many :tables, class_name: 'MxTable', order: :physical_name, dependent: :destroy
  has_many :common_column_sets, class_name: 'MxCommonColumnSet', order: :name, dependent: :destroy
end
