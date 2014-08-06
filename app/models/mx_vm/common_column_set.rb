class MxVm::CommonColumnSet
  include MxVm::VueModel

  attr_accessor :name, :comment, :columns, :lock_version

  def initialize(params={})
    self.columns = []
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxCommonColumnSet)
      build_from_mx_common_column_set(params)
    end
  end

  def valid_with_columns?
    valid_without_columns?
    merge_children_errors!(columns, :column)
    errors.empty?
  end
  alias_method_chain :valid?, :columns

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :comment, :lock_version)
    if params[:columns]
      self.columns = params[:columns].values.map { |column_params| MxVm::CommonColumn.new(column_params) }
    end
  end

  def build_from_mx_common_column_set(common_column_set)
    simple_load_values_from_object!(dbms_product, :id, :name, :comment, :lock_version)
    self.columns = common_column_set.columns.map { |column| MxVm::CommonColumn.new(column) }
  end
end
