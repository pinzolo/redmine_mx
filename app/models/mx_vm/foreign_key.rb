class MxVm::ForeignKey
  include MxVm::VueModel

  def_attr :name, :ref_table_id, :comment, :relations, :position
  attr_accessor :used_foreign_key_names, :belonging_column_ids, :other_table_ids

  validates :name, presence: true,
                   length: { maximum: 255 },
                   exclusion: { in: ->(record){ record.used_foreign_key_names },
                                message: :taken,
                                if: 'name.present?' }
  validates :ref_table_id, inclusion: { in: ->(record){ record.other_table_ids } }
  validates :relations, presence: true

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxForeignKey)
      build_from_mx_foreign_key(params)
    end
    self.relations ||= []
  end

  def ref_table_name
    @ref_table_name ||= MxTable.where(id: ref_table_id).first.try(:physical_name)
  end

  def valid_with_relations?
    if valid_without_relations?
      assign_values_to_relations_for_validation
      merge_children_errors!(relations, :relation)
    end
    errors.empty?
  end
  alias_method_chain :valid?, :relations

  def as_json_with_mx(options = {})
    as_json_without_mx(root: false, methods: [:errors, :relations, :ref_table_name])
  end
  alias_method_chain :as_json, :mx

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :ref_table_id, :comment)
    if params[:relations]
      relation_vms = params[:relations].values.map { |relation_params| MxVm::ForeignKeyRelation.new(relation_params) }
      self.relations = relation_vms.sort_by { |vm| vm.position.to_i }
    end
  end

  def build_from_mx_foreign_key(foreign_key)
    simple_load_values_from_object!(foreign_key, :id, :name, :ref_table_id, :comment)
    self.relations = foreign_key.relations.map { |relation| MxVm::ForeignKeyRelation.new(relation) }
  end

  def assign_values_to_relations_for_validation
    column_ids_in_ref_table = MxTable.find(ref_table_id).columns.map { |column| column.id.to_s }
    valid_positions = [*(0..relations.size-1)].map(&:to_s)
    relations.each do |relation|
      relation.belonging_column_ids = belonging_column_ids
      relation.belonging_column_ids_in_ref_table = column_ids_in_ref_table
      relation.valid_positions = valid_positions
      relation.other_positions = relations.reject { |rel| rel.column_id == relation.column_id }.map(&:position)
    end
  end
end
