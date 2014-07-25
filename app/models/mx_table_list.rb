class MxTableList < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :project
  belongs_to :dbms_product, class_name: 'MxDbmsProduct'
  has_many :tables, class_name: 'MxTable', order: :physical_name, dependent: :destroy
  has_many :common_column_sets, class_name: 'MxCommonColumnSet', order: :name, dependent: :destroy
end
