class MxColumnSet < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :database, class_name: 'MxDatabase', foreign_key: :database_id
  has_many :header_columns, class_name: 'MxHeaderColumn',
                            foreign_key: :owner_id,
                            order: :position,
                            include: [:data_type, :mx_comment],
                            dependent: :destroy
  has_many :footer_columns, class_name: 'MxFooterColumn',
                            foreign_key: :owner_id,
                            order: :position,
                            include: [:data_type, :mx_comment],
                            dependent: :destroy

  def columns
    @columns ||= header_columns + footer_columns
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
    self.attributes = vue_model.params_with(:name, :comment)
    save!
    create_columns!(vue_model)
  end

  def update_with!(vue_model)
    update_attributes!(vue_model.params_with(:name, :comment, :lock_version))
    header_columns.delete_all
    footer_columns.delete_all
    create_columns!(vue_model)
  end

  def create_columns!(vue_model)
    vue_model.header_columns.each do |vm_header_column|
      header_columns.build.save_with!(vm_header_column)
    end
    vue_model.footer_columns.each do |vm_footer_column|
      footer_columns.build.save_with!(vm_footer_column)
    end
  end
end
