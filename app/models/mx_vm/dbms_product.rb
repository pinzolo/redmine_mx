class MxVm::DbmsProduct < MxVm::Base

  attr_accessor :id, :name, :type, :comment, :data_types

  validates :name, presence: true, length: { maximum: 200 }, mx_db_presence: { class_name: 'MxDbmsProduct' }
  validates :type, presence: true, inclusion: { in: MxDbmsProduct::PRODUCT_TYPES.keys, if: 'type.present?' }
  validates_with MxValuesUniquenessValidator, { collection: :data_types, attribute: :name, field: :data_type_name }

  def initialize(params={})
    self.data_types = []
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxDbmsProduct)
      build_from_mx_dbms_product(params)
    end
  end

  def valid_with_data_types?
    valid_without_data_types?
    merge_children_errors!(data_types, :data_type)
    errors.empty?
  end
  alias_method_chain :valid?, :data_types

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :type, :comment)
    if params[:data_types]
      data_type_vms = params[:data_types].values.map { |data_type_params| MxVm::DataType.new(data_type_params) }
      self.data_types = data_type_vms.sort_by { |vm| vm.position }
    end
  end

  def build_from_mx_dbms_product(dbms_product)
    simple_load_values_from_object!(dbms_product, :id, :name, :type, :comment)
    self.data_types = dbms_product.data_types.map { |data_type| MxVm::DataType.new(data_type) }
  end
end

