class MxVm::Index
  include MxVm::VueModel

  attr_accessor :name, :unique, :condition, :comment, :position, :columns, :column_ids,
                :used_index_names, :belonging_column_ids

  validates :name, presence: true,
                   length: { maximum: 255 },
                   exclusion: { in: ->(record){ record.used_index_names }, message: :taken, if: 'name.present?' }
  validates :columns, presence: true
  validates :condition, length: { maximum: 255 }

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxIndex)
      build_from_mx_index(params)
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

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :condition, :comment, :position)
    self.unique = params[:unique].present?
    if params[:columns]
      column_vms = params[:columns].map { |column_id, position| MxVm::IndexColumn.new(column_id: column_id, position: position) }
      self.columns = column_vms.sort_by { |vm| vm.position.to_i }
    end
  end

  def build_from_mx_index(index)
    simple_load_values_from_object!(index, :id, :name, :unique, :condition, :comment)
    self.columns = index.columns_rels.map { |index_column| MxVm::IndexColumn.new(index_column) }
  end

  def assign_values_to_columns_for_validation
    valid_positions = [*(0..columns.size-1)].map(&:to_s)
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
