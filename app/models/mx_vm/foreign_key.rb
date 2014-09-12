class MxVm::ForeignKey
  include MxVm::VueModel

  def_attr :name, :ref_table_id, :comment, :relations
  attr_accessor :used_foreign_key_names, :belonging_column_ids

  validates :name, presence: true,
                   length: { maximum: 255 },
                   exclusion: { in: ->(record){ record.used_foreign_key_names },
                                message: :taken,
                                if: 'name.present?' }
  # TODO: validation for ref_table_id
  validates :relations, presence: true

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxForeignKey)
      build_from_mx_foreign_key(params)
    end
    self.relations ||= []
  end

  def valid_with_relations?
    valid_without_columns?
    assign_values_to_relations_for_validation
    merge_children_errors!(relations, :relation)
    clear_assigned_values_to_relations
    errors.empty?
  end
  alias_method_chain :valid?, :relations

  def as_json_with_mx(options = {})
    as_json_without_mx(root: false, methods: [:errors, :relations])
  end
  alias_method_chain :as_json, :mx

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :ref_table_id, :comment)
    if params[:relations]
      relation_vms = params[:relations].values.map do |relation_params|
        MxVm::ForeignKeyRelatin.new(column_id: relation_params[:column_id],
                                    ref_column_id: relation_params[:ref_column_id],
                                    position: relation_params[:position])
      end
      self.relations = relation_vms.sort_by { |vm| vm.position.to_i }
    end
  end

  def build_from_mx_foreign_key(foreign_key)
    simple_load_values_from_object!(index, :id, :name, :ref_table_id, :comment)
    self.relations = foreign_key.relations.map { |relation| MxVm::ForeignKeyRelatin.new(relation) }
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

  def clear_assigned_values_to_relations
    relations.each do |relation|
      relation.belonging_column_ids = nil
      relation.belonging_column_ids_in_ref_table = nil
      relation.valid_positions = nil
      relation.other_positions = nil
    end
  end
end
