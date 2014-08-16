class MxColumnSet < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :database, class_name: 'MxDatabase', foreign_key: :database_id
  has_many :header_columns, class_name: 'MxHeaderColumn', foreign_key: :owner_id, order: :position, dependent: :destroy
  has_many :footer_columns, class_name: 'MxFooterColumn', foreign_key: :owner_id, order: :position, dependent: :destroy

  def columns
    @columns ||= header_columns + footer_columns
  end

  def save_with!(vue_model)
    ActiveRecord::Base.transaction do
      if self.persisted?
        update_with!(vue_model)
      else
        create_with!(vue_model)
      end
    end
  end

  private

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:name, :comment)
    self.save!
    create_columns!(vue_model)
  end

  def update_with!(vue_model)
    self.update_attributes!(vue_model.params_with(:name, :comment, :lock_version))
    self.header_columns.each(&:destroy)
    self.footer_columns.each(&:destroy)
    create_columns!(vue_model)
  end

  def create_columns!(vue_model)
    vue_model.header_columns.each do |vm_header_column|
      vm_header_params = vm_header_column.params_with(:physical_name, :logical_name, :data_type_id, :size, :scale,
                                                      :nullable, :default_value, :position, :comment)
      self.header_columns.build(vm_header_params).save!
    end
    vue_model.footer_columns.each do |vm_footer_column|
      vm_footer_params = vm_footer_column.params_with(:physical_name, :logical_name, :data_type_id, :size, :scale,
                                                      :nullable, :default_value, :position, :comment)
      self.footer_columns.build(vm_footer_params).save!
    end
  end
end
