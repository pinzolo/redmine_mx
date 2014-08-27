class MxVm::PrimaryKey
  include MxVm::VueModel

  attr_accessor :name, :columns, :column_ids

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxPrimaryKey)
      build_from_mx_primary_key(params)
    end
    self.columns ||= []
    self.column_ids = self.columns.map { |col| col.column_id.to_s }
  end

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
end
