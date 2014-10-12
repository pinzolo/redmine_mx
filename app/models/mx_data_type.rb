class MxDataType < ActiveRecord::Base
  include MxSavingWithVueModel
  unloadable

  private

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:name, :sizable, :scalable)
    save!
  end

  def update_with!(vue_model)
    update_attributes!(vue_model.params_with(:name, :sizable, :scalable))
  end
end
