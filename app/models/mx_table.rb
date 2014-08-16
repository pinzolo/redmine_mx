class MxTable < ActiveRecord::Base
  include MxCommentable
  include MxTaggable
  unloadable

  belongs_to :project
  belongs_to :common_column_set
  belongs_to :created_user, class_name: 'User'
  belongs_to :updated_user, class_name: 'User'
  has_many :table_columns, class_name: 'MxTableColumn', foreign_key: :owner_id, order: :position, dependent: :destroy
  has_many :indices, class_name: 'MxIndex', foreign_key: :table_id, order: :name, dependent: :destroy
  has_many :foreign_keys, class_name: 'MxForeignKey', foreign_key: :table_id, dependent: :destroy
  has_many :versions, class_name: 'MxTableVersion', foreign_key: :table_id, dependent: :destroy

  def columns
    if common_column_set
      common_column_set.header_columns + table_columns + common_column_set.footer_columns
    else
      table_columns
    end
  end
end
