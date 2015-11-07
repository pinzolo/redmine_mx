class MxColumnSet < ActiveRecord::Base
  include MxCommentable
  include MxSavingWithVueModel
  include MxAssocOpts
  unloadable

  belongs_to :database, class_name: 'MxDatabase', foreign_key: :database_id
  has_many :header_columns, *assoc_opts(order: :position,
                                        include: [:data_type, :mx_comment],
                                        class_name: 'MxHeaderColumn',
                                        foreign_key: :owner_id,
                                        dependent: :destroy)
  has_many :footer_columns, *assoc_opts(order: :position,
                                        include: [:data_type, :mx_comment],
                                        class_name: 'MxFooterColumn',
                                        foreign_key: :owner_id,
                                        dependent: :destroy)

  def columns
    @columns ||= header_columns + footer_columns
  end

  private

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:name, :comment)
    save!
    create_columns!(vue_model)
  end

  def update_with!(vue_model)
    update_attributes!(vue_model.params_with(:name, :comment, :lock_version))
    update_columns!(header_columns, vue_model.header_columns)
    update_columns!(footer_columns, vue_model.footer_columns)
  end

  def create_columns!(vue_model)
    vue_model.header_columns.each do |vm_header_column|
      header_columns.build.save_with!(vm_header_column)
    end
    vue_model.footer_columns.each do |vm_footer_column|
      footer_columns.build.save_with!(vm_footer_column)
    end
  end

  def update_columns!(base_columns, vue_model_columns)
    column_ids = vue_model_columns.map { |col| col.id.to_s }
    base_column_ids = base_columns.map { |col| col.id.to_s }
    insert_column_ids = column_ids - base_column_ids
    update_column_ids = base_column_ids & column_ids
    delete_column_ids = base_column_ids - column_ids
    delete_column_ids.each { |id| base_columns.find(id).destroy }
    vue_model_columns.select { |vm_column| update_column_ids.include?(vm_column.id.to_s) }.each do |vm_column|
      base_columns.find(vm_column.id).save_with!(vm_column)
    end
    vue_model_columns.select { |vm_column| insert_column_ids.include?(vm_column.id.to_s) }.each do |vm_column|
      base_columns.build.save_with!(vm_column)
    end
  end
end
