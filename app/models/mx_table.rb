class MxTable < ActiveRecord::Base
  include MxCommentable
  include MxTaggable
  include MxSavingWithVueModel
  unloadable

  # associations {{{

  belongs_to :project
  belongs_to :database, class_name: 'MxDatabase'
  belongs_to :column_set, class_name: 'MxColumnSet'
  belongs_to :created_user, class_name: 'User'
  belongs_to :updated_user, class_name: 'User'
  has_one :primary_key, class_name: 'MxPrimaryKey',
                        foreign_key: :table_id,
                        include: :columns,
                        dependent: :destroy
  has_many :table_columns, class_name: 'MxTableColumn',
                           foreign_key: :owner_id,
                           order: :position,
                           include: [:mx_comment, :data_type],
                           dependent: :destroy
  has_many :indices, class_name: 'MxIndex',
                     foreign_key: :table_id,
                     order: :name,
                     include: [:mx_comment, :columns],
                     dependent: :destroy
  has_many :foreign_keys, class_name: 'MxForeignKey',
                          foreign_key: :table_id,
                          order: :name,
                          include: [:mx_comment, { relations: [:column, :ref_column] }],
                          dependent: :destroy
  has_many :referenced_keys, class_name: 'MxForeignKey',
                             foreign_key: :ref_table_id,
                             order: :name,
                             include: [:mx_comment, { relations: [:column, :ref_column] }]
  has_many :versions, class_name: 'MxTableVersion', foreign_key: :table_id, dependent: :destroy

  # }}}

  def self.find_table(database, id)
    table = where(database_id: database.id, physical_name: id).first || where(database_id: database.id, id: id).first
    raise ActiveRecord::RecordNotFound unless table
    table
  end

  def columns
    if column_set
      column_set.header_columns + table_columns + column_set.footer_columns
    else
      table_columns
    end
  end

  def reload_columns
    column_set.try(:reload)
    table_columns.reload
    columns
  end

  def to_param
    physical_name
  end

  def save_with(vue_model)
    ActiveRecord::Base.transaction do
      save_with!(vue_model)
      reload
      versions.build(version: versions.count + 1,
                     snapshot: snapshot.to_yaml,
                     change_summary: vue_model.change_summary).save!
    end
  end

  def snapshot
    { physical_name: physical_name,
      logical_name: logical_name,
      database: database.identifier,
      primary_key_name: primary_key.try(:name),
      comment: comment }.tap do |data|
      data[:columns] = columns.map do |column|
        { mark: column.mark,
          primary_key_position: primary_key ? primary_key.position_for(column) : nil,
          physical_name: column.physical_name,
          logical_name: column.logical_name,
          data_type_name: column.data_type.name,
          size: column.size,
          scale: column.scale,
          nullable: column.nullable,
          default_value: column.default_value,
          comment: column.comment }
      end
      data[:indices] = indices.map do |index|
        { name: index.name,
          columns: index.column_physical_names.join(', '),
          unique: index.unique,
          condition: index.condition,
          comment: index.comment }
      end
      data[:foreign_keys] = foreign_keys.map do |foreign_key|
        { name: foreign_key.name,
          columns: foreign_key.column_physical_names,
          ref_table: foreign_key.ref_table.physical_name,
          ref_columns: foreign_key.ref_column_physical_names,
          comment: foreign_key.comment }
      end
    end
  end

  private

  # create {{{

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:physical_name, :logical_name, :column_set_id, :comment)
    self.created_user_id = User.current.id
    self.updated_user_id = User.current.id
    save!
    create_table_columns!(vue_model)
    create_primary_key!(vue_model) if vue_model.primary_key.columns.present?
    create_indices!(vue_model) if vue_model.indices.present?
    create_foreign_keys!(vue_model) if vue_model.foreign_keys.present?
  end

  def create_table_columns!(vue_model)
    vue_model.table_columns.each do |vm_column|
      vm_column_params = vm_column.params_with(:physical_name, :logical_name, :data_type_id, :size, :scale,
                                               :nullable, :default_value, :position, :comment)
      table_columns.build(vm_column_params).save!
    end
  end

  def create_primary_key!(vue_model)
    build_primary_key.save_with!(create_primary_key_vue_model_for_saving(vue_model))
  end

  def create_primary_key_vue_model_for_saving(vue_model)
    vue_model.primary_key.dup.tap do |pk_vue_model|
      pk_vue_model.columns.each do |column|
        column_physical_name = vue_model.column_physical_name_for(column.column_id)
        column.column_id = columns.detect { |col| col.physical_name == column_physical_name }.try(:id)
      end
    end
  end

  def create_indices!(vue_model)
    index_vue_models = create_index_vue_models_for_saving(vue_model)
    index_vue_models.each { |vm_index| indices.build.save_with!(vm_index) }
  end

  def create_index_vue_models_for_saving(vue_model)
    vue_model.indices.map do |index_vue_model|
      index_vue_model.dup.tap do |duplicated_index_vue_model|
        duplicated_index_vue_model.columns.each do |column|
          column_physical_name = vue_model.column_physical_name_for(column.column_id)
          column.column_id = columns.detect { |col| col.physical_name == column_physical_name }.try(:id)
        end
      end
    end
  end

  def create_foreign_keys!(vue_model)
    foreign_key_vue_models = create_foreign_key_vue_models_for_saving(vue_model)
    foreign_key_vue_models.each { |vm_foreign_key| foreign_keys.build.save_with!(vm_foreign_key) }
  end

  def create_foreign_key_vue_models_for_saving(vue_model)
    vue_model.foreign_keys.map do |foreign_key_vue_model|
      foreign_key_vue_model.dup.tap do |duplicated_foreign_key_vue_model|
        duplicated_foreign_key_vue_model.relations.each do |relation|
          column_physical_name = vue_model.column_physical_name_for(relation.column_id)
          relation.column_id = columns.detect { |col| col.physical_name == column_physical_name }.try(:id)
        end
      end
    end
  end

  # }}}

  # update {{{

  def update_with!(vue_model)
    self.updated_user_id = User.current.id
    update_attributes!(vue_model.params_with(:physical_name, :logical_name, :column_set_id, :comment, :lock_version))
    update_table_columns!(vue_model)
    delete_unlink_foreign_key_relations
    update_primary_key!(vue_model)
    update_indices!(vue_model)
    update_foreign_keys!(vue_model)
  end

  def update_table_columns!(vue_model)
    column_ids = vue_model.table_columns.map { |col| col.id.to_s }
    base_column_ids = table_columns.map { |col| col.id.to_s }
    delete_columns_for_update!(base_column_ids - column_ids)
    update_columns_for_update!(base_column_ids & column_ids, vue_model)
    create_columns_for_update!(column_ids - base_column_ids, vue_model)
  end

  def delete_columns_for_update!(column_ids)
    column_ids.each { |id| table_columns.find(id).destroy }
  end

  def update_columns_for_update!(column_ids, vue_model)
    cols = vue_model.table_columns.select { |vm_column| column_ids.include?(vm_column.id.to_s) }
    cols.each do |vm_column|
      table_columns.find(vm_column.id).save_with!(vm_column)
    end
  end

  def create_columns_for_update!(column_ids, vue_model)
    cols = vue_model.table_columns.select { |vm_column| column_ids.include?(vm_column.id.to_s) }
    cols.each do |vm_column|
      table_columns.build.save_with!(vm_column)
    end
  end

  def delete_unlink_foreign_key_relations
    column_ids = reload_columns.map(&:id)
    referenced_keys.each do |ref_key|
      ref_key.relations.each do |ref_rel|
        ref_rel.destroy unless column_ids.include?(ref_rel.ref_column_id)
      end
    end
  end

  def update_primary_key!(vue_model)
    if vue_model.primary_key.columns.present?
      vm_primary_key = create_primary_key_vue_model_for_saving(vue_model)
      if primary_key
        primary_key.save_with!(vm_primary_key)
      else
        create_primary_key!(vue_model)
      end
    else
      primary_key.try(:destroy)
    end
  end

  def update_indices!(vue_model)
    index_vue_models = create_index_vue_models_for_saving(vue_model)
    index_ids = index_vue_models.map { |idx| idx.id.to_s }
    base_index_ids = indices.map { |idx| idx.id.to_s }
    delete_indices_for_update!(base_index_ids - index_ids)
    update_indices_for_update!(base_index_ids & index_ids, vue_model)
    create_indices_for_update!(index_ids - base_index_ids, vue_model)
  end

  def delete_indices_for_update!(index_ids)
    index_ids.each { |id| indices.find(id).destroy }
  end

  def update_indices_for_update!(index_ids, vue_model)
    idxs = vue_model.indices.select { |vm_index| index_ids.include?(vm_index.id.to_s) }
    idxs.each do |vm_index|
      indices.find(vm_index.id).save_with!(vm_index)
    end
  end

  def create_indices_for_update!(index_ids, vue_model)
    idxs = vue_model.indices.select { |vm_index| index_ids.include?(vm_index.id.to_s) }
    idxs.each do |vm_index|
      indices.build.save_with!(vm_index)
    end
  end

  def update_foreign_keys!(vue_model)
    foreign_key_vue_models = create_foreign_key_vue_models_for_saving(vue_model)
    foreign_key_ids = foreign_key_vue_models.map { |fk| fk.id.to_s }
    base_foreign_key_ids = foreign_keys.map { |fk| fk.id.to_s }
    delete_foreign_keys_for_update!(base_foreign_key_ids - foreign_key_ids)
    update_foreign_keys_for_update!(base_foreign_key_ids & foreign_key_ids, vue_model)
    create_foreign_keys_for_update!(foreign_key_ids - base_foreign_key_ids, vue_model)
  end

  def delete_foreign_keys_for_update!(foreign_key_ids)
    foreign_key_ids.each { |id| foreign_keys.find(id).destroy }
  end

  def update_foreign_keys_for_update!(foreign_key_ids, vue_model)
    idxs = vue_model.foreign_keys.select { |vm_foreign_key| foreign_key_ids.include?(vm_foreign_key.id.to_s) }
    idxs.each do |vm_foreign_key|
      foreign_keys.find(vm_foreign_key.id).save_with!(vm_foreign_key)
    end
  end

  def create_foreign_keys_for_update!(foreign_key_ids, vue_model)
    idxs = vue_model.foreign_keys.select { |vm_foreign_key| foreign_key_ids.include?(vm_foreign_key.id.to_s) }
    idxs.each do |vm_foreign_key|
      foreign_keys.build.save_with!(vm_foreign_key)
    end
  end

  # }}}
end
