class MxColumn < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :data_type, class_name: 'MxDataType'

  before_save :adujest_attribute_values

  def adujest_attribute_values
    self.size = nil unless self.data_type.sizable
    self.scale = nil unless self.data_type.scalable
  end
end
