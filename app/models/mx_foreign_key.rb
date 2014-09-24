class MxForeignKey < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :table, class_name: 'MxTable'
  belongs_to :ref_table, class_name: 'MxTable'
  has_many :relations, class_name: 'MxForeignKeyRelation', foreign_key: :foreign_key_id, order: :position, dependent: :destroy

  def save_with!(vue_model)
    ActiveRecord::Base.transaction do
      if persisted?
        update_with!(vue_model)
      else
        create_with!(vue_model)
      end
    end
  end

  def create_with!(vue_model)
    self.attributes = vue_model.params_with(:name, :ref_table_id, :comment)
    save!
    vue_model.relations.each do |vm_relation|
      relations.build.save_with!(vm_relation)
    end
  end

  def update_with!(vue_model)
    update_attributes!(vue_model.params_with(:name, :ref_table_id, :comment))
    #TODO: update relations
  end
end
