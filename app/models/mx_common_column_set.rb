class MxCommonColumnSet < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :table_list, class_name: 'MxTableList', foreign_key: :table_list_id
  has_many :header_columns, class_name: 'MxCommonHeaderColumn', order: :position, dependent: :destroy
  has_many :footer_columns, class_name: 'MxCommonFooterColumn', order: :position, dependent: :destroy
end
