class MxDataType < ActiveRecord::Base
  unloadable

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
    self.attributes = vue_model.params_with(:name, :sizable, :scalable)
    save!
  end

  def update_with!(vue_model)
    update_attributes!(vue_model.params_with(:name, :sizable, :scalable))
  end
end
