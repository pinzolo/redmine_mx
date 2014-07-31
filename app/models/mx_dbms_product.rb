class MxDbmsProduct < ActiveRecord::Base
  include MxCommentable
  unloadable

  has_many :data_types, class_name: 'MxDataType', foreign_key: :dbms_product_id, order: :name, dependent: :destroy

  PRODUCT_TYPES = { 'postgresql' => 'PostgreSQL', 'mysql' => 'MySQL', 'oracle' => 'Oracle', 'sql_server' => 'SQL Server', 'other' => 'Other'}.freeze
  PRODUCT_CLASSES = { 'postgresql' => MxDbms::Postgresql, 'mysql' => MxDbms::Mysql, 'oracle' => MxDbms::Oracle, 'sql_server' => MxDbms::SqlServer, 'other' => MxDbms::Other}.freeze

  class << self
    def find_sti_class(type_name)
      "MxDbms::#{type_name.camelize}".constantize
    end

    def sti_name
      name.underscore.split('/').last
    end
  end

  def type_name
    PRODUCT_TYPES[type]
  end

  def save_with!(vm)
    ActiveRecord::Base.transaction do
      if self.persisted?
        update_with!(vm)
      else
        create_with!(vm)
      end
    end
  end

  private

  def create_with!(vm)
    self.attributes = vm.params_with(:name, :comment)
    self.save!
    vm.data_types.each do |vm_data_type|
      self.data_types.build(vm_data_type.params_with(:name, :sizable, :scalable, :use_by_default)).save!
    end
  end

  def update_with!(vm)
    self.update_attributes!(vm.params_with(:name, :comment, :lock_version))
    self.update_attribute(:type, vm.type)
    base_data_types = Hash[self.data_types.map { |data_type| [data_type.name, data_type] }]
    vm.data_types.each do |vm_data_type|
      base_data_type = base_data_types.delete(vm_data_type.name)
      data_type_params = vm_data_type.params_with(:name, :sizable, :scalable, :use_by_default)
      if base_data_type
        base_data_type.update_attributes!(data_type_params)
      else
        self.data_types.build(data_type_params).save!
      end
    end
    base_data_types.values.each(&:destroy)
  end
end

