class MxTable < ActiveRecord::Base
  include MxCommentable
  include MxTaggable
  unloadable

  belongs_to :project
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
  has_many :foreign_keys, class_name: 'MxForeignKey', foreign_key: :table_id, dependent: :destroy
  has_many :versions, class_name: 'MxTableVersion', foreign_key: :table_id, dependent: :destroy

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

  def to_param
    physical_name
  end

  def save_with!(vue_model)
    ActiveRecord::Base.transaction do
      if persisted?
        update_with!(vue_model)
      else
        create_with!(vue_model)
      end
    end
  end

  private

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:physical_name, :logical_name, :column_set_id, :comment)
    self.created_user_id = User.current.id
    self.updated_user_id = User.current.id
    save!
    create_table_columns!(vue_model)
    create_primary_key!(vue_model) if vue_model.primary_key.columns.present?
  end

  def create_table_columns!(vue_model)
    vue_model.table_columns.each do |vm_column|
      vm_column_params = vm_column.params_with(:physical_name, :logical_name, :data_type_id, :size, :scale,
                                               :nullable, :default_value, :position, :comment)
      table_columns.build(vm_column_params).save!
    end
  end

  def create_primary_key!(vue_model)
    build_primary_key.save_with!(create_primary_key_vue_model_for_db(vue_model))
  end

  def create_primary_key_vue_model_for_db(vue_model)
    pk_vue_model = vue_model.primary_key.dup
    pk_vue_model.columns.each do |column|
      column_physical_name = vue_model.column_physical_name_for(column.column_id)
      column.column_id = columns.detect { |col| col.physical_name == column_physical_name }.try(:id)
    end
    pk_vue_model
  end

  def update_with!(vue_model)
    self.updated_user_id = User.current.id
    update_attributes!(vue_model.params_with(:physical_name, :logical_name, :column_set_id, :comment, :lock_version))
    update_table_columns!(vue_model)
    if vue_model.primary_key.columns.present?
      vm_primary_key = create_primary_key_vue_model_for_db(vue_model)
      if primary_key
        primary_key.save_with!(vm_primary_key)
      else
        create_primary_key!(vue_model)
      end
    else
      primary_key.try(:destroy)
    end
  end

  def update_table_columns!(vue_model)
    column_ids = vue_model.table_columns.map { |col| col.id.to_s }
    base_column_ids = table_columns.map { |col| col.id.to_s }
    insert_column_ids = column_ids - base_column_ids
    update_column_ids = base_column_ids & column_ids
    delete_column_ids = base_column_ids - column_ids
    delete_column_ids.each { |id| table_columns.find(id).destroy }
    vue_model.table_columns.select { |vm_column| update_column_ids.include?(vm_column.id.to_s) }.each do |vm_column|
      table_columns.find(vm_column.id).save_with!(vm_column)
    end
    vue_model.table_columns.select { |vm_column| insert_column_ids.include?(vm_column.id.to_s) }.each do |vm_column|
      table_columns.build.save_with!(vm_column)
    end
  end
end
