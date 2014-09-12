class MxVm::DbmsProduct
  include MxVm::VueModel

  def_attr :name, :type, :comment, :lock_version, :data_types

  validates :name, presence: true, length: { maximum: 255 }, mx_db_absence: { class_name: 'MxDbmsProduct' }
  validates :type, presence: true, inclusion: { in: MxDbmsProduct::PRODUCT_TYPES.keys, if: 'type.present?' }

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
    assign_values_to_data_types_for_validation
    merge_children_errors!(data_types, :data_type)
    clear_assigned_values_to_data_types
    errors.empty?
  end
  alias_method_chain :valid?, :data_types

  def as_json_with_mx(options = {})
    as_json_without_mx(root: false, methods: [:errors])
  end
  alias_method_chain :as_json, :mx

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :type, :comment, :lock_version)
    if params[:data_types]
      data_type_vms = params[:data_types].values.map { |data_type_params| MxVm::DataType.new(data_type_params) }
      self.data_types = data_type_vms.sort_by { |vm| vm.position.to_i }
    end
  end

  def build_from_mx_dbms_product(dbms_product)
    simple_load_values_from_object!(dbms_product, :id, :name, :type, :comment, :lock_version)
    self.data_types = dbms_product.data_types.map { |data_type| MxVm::DataType.new(data_type) }
  end

  def assign_values_to_data_types_for_validation
    self.data_types.each do |data_type|
      data_type.using_names = self.data_types.reject { |dt| dt.id == data_type.id }.map(&:name)
    end
  end

  def clear_assigned_values_to_data_types
    self.data_types.each do |data_type|
      data_type.using_names = nil
    end
  end
end

