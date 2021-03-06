class MxDbmsProduct < ActiveRecord::Base
  include MxCommentable
  include MxSavingWithVueModel
  include MxAssocOpts
  unloadable

  has_many :data_types, *assoc_opts(order: :name,
                                    class_name: 'MxDataType',
                                    foreign_key: :dbms_product_id,
                                    dependent: :destroy)

  PRODUCT_TYPES = { 'MxDbms::Postgresql' => 'PostgreSQL', 'MxDbms::Mysql' => 'MySQL', 'MxDbms::Oracle' => 'Oracle', 'MxDbms::SqlServer' => 'SQL Server', 'MxDbms::Other' => 'Other'}.freeze

  def type_name
    PRODUCT_TYPES[type]
  end

  private

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:name, :comment)
    save!
    vue_model.data_types.each do |vm_data_type|
      data_types.build.save_with!(vm_data_type)
    end
  end

  def update_with!(vue_model)
    update_attributes!(vue_model.params_with(:name, :comment, :lock_version))
    update_attribute(:type, vue_model.type)
    base_data_types = Hash[data_types.map { |data_type| [data_type.name, data_type] }]
    vue_model.data_types.each do |vm_data_type|
      data_type = base_data_types.delete(vm_data_type.name) || data_types.build
      data_type.save_with!(vm_data_type)
    end
    base_data_types.values.each(&:destroy)
  end
end

