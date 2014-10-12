class MxColumn < ActiveRecord::Base
  include MxCommentable
  include MxSavingWithVueModel
  unloadable

  belongs_to :data_type, class_name: 'MxDataType'

  before_save :adujest_attribute_values

  def adujest_attribute_values
    self.size = nil unless self.data_type.sizable
    self.scale = nil unless self.data_type.scalable
  end

  private

  def create_with!(vue_model)
    self.attributes = params_for_save(vue_model)
    save!
  end

  def update_with!(vue_model)
    update_attributes!(params_for_save(vue_model))
  end

  def params_for_save(vue_model)
    vue_model.params_with(:physical_name, :logical_name, :data_type_id, :size, :scale,
                          :nullable, :default_value, :position, :comment)
  end
end
