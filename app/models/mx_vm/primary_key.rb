class MxVm::PrimaryKey
  include MxVm::VueModel

  attr_accessor :name, :comment, :column_ids

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxPrimaryKey)
      build_from_mx_primary_key(params)
    end
    self.column_ids ||= []
  end

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :comment, :column_ids)
  end

  def build_from_mx_primary_key(primary_key)
    simple_load_values_from_object!(column_set, :id, :name, :comment)
    self.column_ids = primary_key.columns_rels.map { |column_rel| column_rel.column_id.to_s }
  end
end
