class MxVm::PrimaryKey
  include MxVm::VueModel

  def_attr :name, :columns, :column_ids
  attr_accessor :used_primary_key_names, :belonging_column_ids

  validates :name, length: { maximum: 255 }, exclusion: { in: ->(record){ record.used_primary_key_names }, message: :taken, if: 'name.present?' }

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxPrimaryKey)
      build_from_mx_primary_key(params)
    end
    self.columns ||= []
    self.column_ids = columns.map { |col| col.column_id.to_s }
  end

  def valid_with_columns?
    valid_without_columns?
    assign_values_to_columns_for_validation
    merge_children_errors!(columns, :column)
    clear_assigned_values_to_columns
    errors.empty?
  end
  alias_method_chain :valid?, :columns

  def as_json_with_mx(options = {})
    as_json_without_mx(root: false, methods: [:errors, :columns])
  end
  alias_method_chain :as_json, :mx

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :name)
    if params[:columns]
      column_vms = params[:columns].map { |column_id, position| MxVm::PrimaryKeyColumn.new(column_id: column_id, position: position) }
      self.columns = column_vms.sort_by { |vm| vm.position.to_i }
    end
  end

  def build_from_mx_primary_key(primary_key)
    simple_load_values_from_object!(primary_key, :name)
    self.columns = primary_key.columns_rels.map { |primary_key_column| MxVm::PrimaryKeyColumn.new(primary_key_column) }
  end

  def assign_values_to_columns_for_validation
    valid_positions = [*(1..columns.size)].map(&:to_s)
    self.columns.each do |column|
      column.belonging_column_ids = belonging_column_ids
      column.valid_positions = valid_positions
      column.other_positions = self.columns.reject { |col| col.column_id == column.column_id }.map(&:position)
    end
  end

  def clear_assigned_values_to_columns
    self.columns.each do |column|
      column.belonging_column_ids = nil
      column.valid_positions = nil
      column.other_positions = nil
    end
  end
end
