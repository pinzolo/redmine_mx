class MxIndex < ActiveRecord::Base
  include MxCommentable
  include MxSavingWithVueModel
  unloadable

  belongs_to :table, class_name: 'MxTable'
  has_many :columns_rels, ->{ order(:position) },
                          class_name: 'MxIndexColumn',
                          foreign_key: :index_id,
                          dependent: :destroy
  has_many :columns, through: :columns_rels

  def column_physical_names
    columns.map(&:physical_name)
  end

  private

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:name, :unique, :condition, :comment)
    save!
    vue_model.columns.each do |vm_index_column|
      columns_rels.build.save_with!(vm_index_column)
    end
  end

  def update_with!(vue_model)
    update_attributes!(vue_model.params_with(:name, :unique, :condition, :comment))
    update_column_rels!(vue_model)
  end

  def update_column_rels!(vue_model)
    column_ids = vue_model.columns.map { |col| col.column_id.to_s }
    base_column_ids = columns_rels.map { |col| col.column_id.to_s }
    delete_column_rels_for_update!(base_column_ids - column_ids)
    update_column_rels_for_update!(base_column_ids & column_ids, vue_model)
    create_column_rels_for_update!(column_ids - base_column_ids, vue_model)
  end

  def delete_column_rels_for_update!(column_ids)
    column_ids.each { |column_id| columns_rels.where(column_id: column_id).first.destroy }
  end

  def create_column_rels_for_update!(column_ids, vue_model)
    cols = vue_model.columns.select { |vm_pk_column| column_ids.include?(vm_pk_column.column_id.to_s) }
    cols.each { |vm_pk_column| columns_rels.build.save_with!(vm_pk_column) }
  end

  def update_column_rels_for_update!(column_ids , vue_model)
    cols = vue_model.columns.select { |vm_pk_column| column_ids.include?(vm_pk_column.column_id.to_s) }
    cols.each { |vm_pk_column| columns_rels.where(column_id: vm_pk_column.column_id).first.save_with!(vm_pk_column) }
  end
end
