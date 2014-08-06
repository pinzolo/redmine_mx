class MxCommonColumnSet < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :database, class_name: 'MxDatabase', foreign_key: :database_id
  has_many :header_columns, class_name: 'MxCommonHeaderColumn', order: :position, dependent: :destroy
  has_many :footer_columns, class_name: 'MxCommonFooterColumn', order: :position, dependent: :destroy

  def columns
    @columns ||= header_columns + footer_columns
  end
end
