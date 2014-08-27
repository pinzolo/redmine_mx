class MxPrimaryKey < ActiveRecord::Base
  unloadable

  belongs_to :table, class_name: 'MxTable'
  has_many :columns_rels, class_name: 'MxPrimaryKeyColumn', foreign_key: :primary_key_id, order: :position, dependent: :destroy
  has_many :columns, through: :columns_rels

  def position_for(column)
    columns_rels.detect { |pk_col| pk_col.column_id == column.id }.try(:position)
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
    self.name = vue_model.name
    save!
    vue_model.columns.each do |vm_pk_column|
      columns_rels.build.save_with!(vm_pk_column)
    end
  end

  def update_with!(vue_model)
  end
end
