class MxForeignKeyRelation < ActiveRecord::Base
  include MxSavingWithVueModel
  unloadable

  belongs_to :column, class_name: 'MxColumn'
  belongs_to :ref_column, class_name: 'MxColumn'

  private

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:column_id, :ref_column_id, :position)
    save!
  end

  def update_with!(vue_model)
    self.update_attributes!(vue_model.params_with(:column_id, :ref_column_id, :position))
  end
end
