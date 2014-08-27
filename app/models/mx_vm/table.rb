class MxVm::Table
  include MxVm::VueModel
  attr_accessor :physical_name, :logical_name, :database_id, :column_set_id, :table_columns, :comment, :lock_version
  attr_accessor :primary_key
  attr_accessor :data_types, :column_sets

  validates :physical_name, presence: true, length: { maximum: 200 }, mx_db_absence: { class_name: 'MxTable', scope: :database_id }
  validates :logical_name, length: { maximum: 200 }
  validates :column_set_id, inclusion: { in: ->(table){ table.column_sets.map { |col_set| col_set.id.to_s } }, if: 'column_set_id.present?' }

  def initialize(params = {}, database = {})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxTable)
      build_from_mx_table(params)
    end
    if database
      self.database_id = database.id
      self.data_types = database.dbms_product.data_types.map { |data_type| MxVm::DataType.new(data_type) }
      self.column_sets = database.column_sets.map { |column_set| MxVm::ColumnSet.new(column_set) }
    end
    safe_collections
  end

  def column_set
    return nil unless column_set_id
    @column_set ||= MxColumnSet.where(id: column_set_id).first
  end

  def columns
    if column_set
      column_set.header_columns + table_columns + column_set.footer_columns
    else
      table_columns
    end
  end

  def column_physical_name_for(id)
    self.columns.detect { |column| column.id.to_s == id.to_s }.try(:physical_name)
  end

  def valid_with_children?
    valid_without_children?
    assign_values_to_columns_for_validation
    merge_children_errors!(table_columns, :column)
    clear_assigned_values_to_columns
    errors.empty?
  end
  alias_method_chain :valid?, :children

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :physical_name, :logical_name, :database_id, :column_set_id, :comment, :lock_version)
    self.table_columns = params[:table_columns].values.map { |column_params| MxVm::Column.new(column_params) } if params[:table_columns]
    self.primary_key = MxVm::PrimaryKey.new(params[:primary_key])
  end

  def build_from_mx_table(table)
    simple_load_values_from_object!(table, :id, :physical_name, :logical_name, :database_id, :column_set_id, :comment, :lock_version)
    self.table_columns = table.table_columns.map { |column| MxVm::Column.new(column) }
    self.primary_key = MxVm::PrimaryKey.new(table.primary_key)
  end

  def safe_collections
    self.table_columns ||= []
    self.data_types ||= []
    self.column_sets ||= []
  end

  def assign_values_to_columns_for_validation
    data_type_ids = self.data_types.map { |data_type| data_type.id.to_s }
    self.table_columns.each do |column|
      column.data_type_ids = data_type_ids
      column.using_physical_names = self.columns.reject { |col| col.id == column.id }.map(&:physical_name)
    end
  end

  def clear_assigned_values_to_columns
    self.table_columns.each do |column|
      column.data_type_ids = nil
      column.using_physical_names = nil
    end
  end
end
