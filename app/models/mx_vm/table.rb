class MxVm::Table
  include MxVm::VueModel
  def_attr :physical_name, :logical_name, :database_id, :column_set_id, :table_columns, :comment, :lock_version,
           :primary_key, :indices, :foreign_keys,
           :data_types, :column_sets

  validates :physical_name, presence: true, length: { maximum: 255 }, mx_db_absence: { class_name: 'MxTable', scope: :database_id }
  validates :logical_name, length: { maximum: 255 }
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
    columns.detect { |column| column.id.to_s == id.to_s }.try(:physical_name)
  end

  def valid_with_children?
    valid_without_children?
    assign_values_for_validation
    merge_children_errors!(table_columns, :column)
    merge_children_errors!([primary_key], :primary_key)
    merge_children_errors!(indices, :index)
    merge_children_errors!(foreign_keys, :foreign_key)
    clear_assigned_values
    errors.empty?
  end
  alias_method_chain :valid?, :children

  def as_json_with_mx(options = {})
    as_json_without_mx(root: false, methods: [:errors, :column_sets, :data_types, :table_columns, :primary_key, :indices, :foreign_keys])
  end
  alias_method_chain :as_json, :mx

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :physical_name, :logical_name, :database_id, :column_set_id, :comment, :lock_version)
    if params[:table_columns]
      self.table_columns = params[:table_columns].values.map { |column_params| MxVm::Column.new(column_params) }.sort_by { |col| col.position.to_i }
    end
    self.primary_key = MxVm::PrimaryKey.new(params[:primary_key])
    if params[:indices]
      self.indices = params[:indices].values.map { |index_params| MxVm::Index.new(index_params) }.sort_by { |idx| idx.position.to_i}
    end
    if params[:foreign_keys]
      self.foreign_keys = params[:foreign_keys].values.map { |foreign_key_params| MxVm::ForeignKey.new(foreign_keys) }.sort_by { |fk| fk.position.to_i }
    end
  end

  def build_from_mx_table(table)
    simple_load_values_from_object!(table, :id, :physical_name, :logical_name, :database_id, :column_set_id, :comment, :lock_version)
    self.table_columns = table.table_columns.map { |column| MxVm::Column.new(column) }
    self.primary_key = MxVm::PrimaryKey.new(table.primary_key)
    self.indices = table.indices.map { |index| MxVm::Index.new(index) }
    self.foreign_keys = table.foreign_keys.map { |foreign_key| MxVm::ForeignKey.new(foreign_key) }
  end

  def safe_collections
    self.table_columns ||= []
    self.data_types ||= []
    self.column_sets ||= []
    self.indices ||= []
    self.foreign_keys ||= []
  end

  def assign_values_for_validation
    assign_values_for_columns_validation

    other_tables = MxDatabase.includes(tables: :indices).find(database_id).tables.reject { |table| table.id.to_s == self.id.to_s }
    belonging_column_ids = columns.map { |column| column.id.to_s }

    assign_values_for_primary_key_validation(other_tables, belonging_column_ids)
    assign_values_for_indices_validation(other_tables, belonging_column_ids)
  end

  def assign_values_for_columns_validation
    data_type_ids = data_types.map { |data_type| data_type.id.to_s }
    table_columns.each do |column|
      column.data_type_ids = data_type_ids
      column.using_physical_names = columns.reject { |col| col.id == column.id }.map(&:physical_name)
    end
  end

  def assign_values_for_primary_key_validation(other_tables, belonging_column_ids)
    primary_key.used_primary_key_names = other_tables.map { |table| table.primary_key.try(:name).presence }.compact
    primary_key.belonging_column_ids = belonging_column_ids
  end

  def assign_values_for_indices_validation(other_tables, belonging_column_ids)
    other_index_names = other_tables.map { |table| table.indices.map(&:name) }.flatten
    indices.each do |index|
      index.used_index_names = other_index_names + indices.reject { |idx| idx.id.to_s == index.id.to_s }.map(&:name)
      index.belonging_column_ids = belonging_column_ids
    end
  end

  def assign_values_for_foreign_keys_validation(other_tables, belonging_column_ids)
    other_foreign_key_names = other_tables.map { |table| table.foreign_keys.map(&:name) }.flatten
    foreign_keys.each do |foreign_key|
      foreign_key.used_foreign_key_names = other_foreign_key_names + foreign_keys.reject { |fkey| fkey.id.to_s == foreign_key.id.to_s }.map(&:name)
      foreign_key.belonging_column_ids = belonging_column_ids
    end
  end

  def clear_assigned_values
    clear_assigned_values_of_columns
    clear_assigned_values_of_primary_key
    clear_assigned_values_of_indices
    clear_assigned_values_of_foreign_keys
  end

  def clear_assigned_values_of_columns
    table_columns.each do |column|
      column.data_type_ids = nil
      column.using_physical_names = nil
    end
  end

  def clear_assigned_values_of_primary_key
    primary_key.used_primary_key_names = nil
    primary_key.belonging_column_ids = nil
  end

  def clear_assigned_values_of_indices
    indices.each do |index|
      index.used_index_names = nil
      index.belonging_column_ids = nil
    end
  end

  def clear_assigned_values_of_foreign_keys
    foreign_keys.each do |foreign_key|
      foreign_key.used_foreign_key_names = nil
      foreign_key.belonging_column_ids = nil
    end
  end
end
