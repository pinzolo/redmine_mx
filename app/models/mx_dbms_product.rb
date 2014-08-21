class MxDbmsProduct < ActiveRecord::Base
  include MxCommentable
  unloadable

  has_many :data_types, class_name: 'MxDataType', foreign_key: :dbms_product_id, order: :name, dependent: :destroy

  PRODUCT_TYPES = { 'MxDbms::Postgresql' => 'PostgreSQL', 'MxDbms::Mysql' => 'MySQL', 'MxDbms::Oracle' => 'Oracle', 'MxDbms::SqlServer' => 'SQL Server', 'MxDbms::Other' => 'Other'}.freeze

  def type_name
    PRODUCT_TYPES[type]
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
    vue_model.data_types.each do |vm_data_type|
      self.data_types.build(vm_data_type.params_with(:name, :sizable, :scalable)).save!
    end
  end

  def update_with!(vue_model)
    self.update_attributes!(vue_model.params_with(:name, :comment, :lock_version))
    self.update_attribute(:type, vue_model.type)
    base_data_types = Hash[self.data_types.map { |data_type| [data_type.name, data_type] }]
    vue_model.data_types.each do |vm_data_type|
      base_data_type = base_data_types.delete(vm_data_type.name)
      data_type_params = vm_data_type.params_with(:name, :sizable, :scalable)
      if base_data_type
        base_data_type.update_attributes!(data_type_params)
      else
        self.data_types.build(data_type_params).save!
      end
    end
    base_data_types.values.each(&:destroy)
  end
end

