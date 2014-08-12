class MxVm::CommonColumnSet
  include MxVm::VueModel

  attr_accessor :name, :database_id, :comment, :data_types, :header_columns, :footer_columns, :lock_version

  def initialize(params={})
    self.header_columns = []
    self.footer_columns = []
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxCommonColumnSet)
      build_from_mx_common_column_set(params)
    end
  end

  def valid_with_columns?
    valid_without_columns?
    merge_children_errors!(header_columns, :header_column)
    merge_children_errors!(footer_columns, :footer_column)
    errors.empty?
  end
  alias_method_chain :valid?, :columns

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :database_id, :comment, :lock_version)
    if params[:header_columns]
      self.header_columns = params[:header_columns].values.map { |column_params| MxVm::CommonColumn.new(column_params) }
    end
    if params[:footer_columns]
      self.footer_columns = params[:footer_columns].values.map { |column_params| MxVm::CommonColumn.new(column_params) }
    end
  end

  def build_from_mx_common_column_set(common_column_set)
    simple_load_values_from_object!(common_column_set, :id, :name, :database_id, :comment, :lock_version)
    self.header_columns = common_column_set.header_columns.map { |column| MxVm::CommonColumn.new(column) }
    self.footer_columns = common_column_set.footer_columns.map { |column| MxVm::CommonColumn.new(column) }
  end
end
