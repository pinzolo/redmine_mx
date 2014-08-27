class MxPrimaryKeyColumn < ActiveRecord::Base
  unloadable

  belongs_to :column, class_name: 'MxColumn'

  def save_with!(vue_model)
    ActiveRecord::Base.transaction do
      if persisted?
        update_with!(vue_model)
      else
        create_with!(vue_model)
      end
    end
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
