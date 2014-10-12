module MxColumnAndPosition
  extend ActiveSupport::Concern
  include MxSavingWithVueModel

  included do
    unloadable
    belongs_to :column, class_name: 'MxColumn'
  end

  private

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:column_id, :position)
    save!
  end

  def update_with!(vue_model)
    self.update_attributes!(vue_model.params_with(:column_id, :position))
  end
end
