class MxTable < ActiveRecord::Base
  include MxCommentable
  include MxTaggable
  unloadable

  belongs_to :project
  belongs_to :column_set, class_name: 'MxColumnSet'
  belongs_to :created_user, class_name: 'User'
  belongs_to :updated_user, class_name: 'User'
  has_many :table_columns, class_name: 'MxTableColumn',
                           foreign_key: :owner_id,
                           order: :position,
                           include: [:mx_comment, :data_type],
                           dependent: :destroy
  has_many :indices, class_name: 'MxIndex', foreign_key: :table_id, order: :name, dependent: :destroy
  has_many :foreign_keys, class_name: 'MxForeignKey', foreign_key: :table_id, dependent: :destroy
  has_many :versions, class_name: 'MxTableVersion', foreign_key: :table_id, dependent: :destroy

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
      if self.persisted?
        update_with!(vue_model)
      else
        create_with!(vue_model)
      end
    end
  end

  private

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:physical_name, :logical_name, :column_set_id, :comment)
    self.save!
    vue_model.table_columns.each do |vm_column|
      vm_column_params = vm_column.params_with(:physical_name, :logical_name, :data_type_id, :size, :scale,
                                               :nullable, :default_value, :position, :comment)
      self.table_columns.build(vm_column_params).save!
    end
  end

  def update_with!(vue_model)
    self.update_attributes!(vue_model.params_with(:physical_name, :logical_name, :column_set_id, :comment, :lock_version))
    #TODO: table_columns
  end
end
