class MxForeignKey < ActiveRecord::Base
  include MxCommentable
  include MxSavingWithVueModel
  unloadable

  belongs_to :table, class_name: 'MxTable'
  belongs_to :ref_table, class_name: 'MxTable'
  has_many :relations, class_name: 'MxForeignKeyRelation', foreign_key: :foreign_key_id, order: :position, dependent: :destroy

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:name, :ref_table_id, :comment)
    save!
    vue_model.relations.each do |vm_relation|
      relations.build.save_with!(vm_relation)
    end
  end

  def update_with!(vue_model)
    update_attributes!(vue_model.params_with(:name, :ref_table_id, :comment))
    update_relations!(vue_model)
  end

  def update_relations!(vue_model)
    column_ids = vue_model.relations.map { |rel| rel.column_id.to_s }
    base_column_ids = relations.map { |rel| rel.column_id.to_s }
    delete_relations_for_update!(base_column_ids - column_ids)
    update_relations_for_update!(base_column_ids & column_ids, vue_model)
    create_relations_for_update!(column_ids - base_column_ids, vue_model)
  end

  def delete_relations_for_update!(column_ids)
    column_ids.each { |column_id| relations.where(column_id: column_id).first.destroy }
  end

  def create_relations_for_update!(column_ids, vue_model)
    vm_rels = vue_model.relations.select { |vm_relation| column_ids.include?(vm_relation.column_id.to_s) }
    vm_rels.each { |vm_relation| relations.build.save_with!(vm_relation) }
  end

  def update_relations_for_update!(column_ids , vue_model)
    vm_rels = vue_model.relations.select { |vm_relation| column_ids.include?(vm_relation.column_id.to_s) }
    vm_rels.each { |vm_relation| relations.where(column_id: vm_relation.column_id).first.save_with!(vm_relation) }
  end
end
