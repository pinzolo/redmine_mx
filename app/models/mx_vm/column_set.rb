class MxVm::ColumnSet
  include MxVm::VueModel

  attr_accessor :name, :database_id, :comment, :data_types, :header_columns, :footer_columns, :lock_version

  validates :name, presence: true, length: { maximum: 255 }, mx_db_absence: { class_name: 'MxColumnSet', scope: :database_id }

  def initialize(params={}, database=nil)
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxColumnSet)
      build_from_mx_column_set(params)
    end
    if database
      self.database_id = database.id
      self.data_types = database.dbms_product.data_types.map { |data_type| MxVm::DataType.new(data_type) }
    end
    safe_collections
  end

  def columns
    header_columns + footer_columns
  end

  def valid_with_columns?
    valid_without_columns?
    assign_values_to_columns_for_validation
    merge_children_errors!(header_columns, :header_column)
    merge_children_errors!(footer_columns, :footer_column)
    clear_assigned_values_to_columns
    errors.empty?
  end
  alias_method_chain :valid?, :columns

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :database_id, :comment, :lock_version)
    self.header_columns = params[:header_columns].values.map { |column_params| MxVm::Column.new(column_params) } if params[:header_columns]
    self.footer_columns = params[:footer_columns].values.map { |column_params| MxVm::Column.new(column_params) } if params[:footer_columns]
  end

  def build_from_mx_column_set(column_set)
    simple_load_values_from_object!(column_set, :id, :name, :database_id, :comment, :lock_version)
    self.header_columns = column_set.header_columns.map { |column| MxVm::Column.new(column) }
    self.footer_columns = column_set.footer_columns.map { |column| MxVm::Column.new(column) }
  end

  def safe_collections
    self.header_columns ||= []
    self.footer_columns ||= []
    self.data_types ||= []
  end

  def assign_values_to_columns_for_validation
    data_type_ids = data_types.map { |data_type| data_type.id.to_s }
    columns.each do |column|
      column.data_type_ids = data_type_ids
      column.using_physical_names = columns.reject { |col| col.id == column.id }.map(&:physical_name)
    end
  end

  def clear_assigned_values_to_columns
    columns.each do |column|
      column.data_type_ids = nil
      column.using_physical_names = nil
    end
  end
end
