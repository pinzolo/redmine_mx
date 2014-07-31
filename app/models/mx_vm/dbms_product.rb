class MxVm::DbmsProduct < MxVm::Base

  attr_accessor :name, :type, :comment, :data_types

  validates :name, presence: true
  validates :type, presence: true

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
    simple_load_values_from_hash!(params, :name, :type, :comment)
    if params[:data_types]
      self.data_types = params[:data_types].values.map { |data_type_params| MxVm::DataType.new(data_type_params) }.sort_by(&:name)
    end
  end

  def build_from_mx_dbms_product(dbms_product)
    simple_load_values_from_object!(dbms_product, :name, :type, :comment)
    self.data_types = dbms_product.data_types.map { |data_type| MxVm::DataType.new(data_type) }
  end
end

