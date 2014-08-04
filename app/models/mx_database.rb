class MxDatabase < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :project
  belongs_to :dbms_product, class_name: 'MxDbmsProduct'
  has_many :tables, class_name: 'MxTable', foreign_key: :database_id, order: :physical_name, dependent: :destroy
  has_many :common_column_sets, class_name: 'MxCommonColumnSet', foreign_key: :database_id, order: :name, dependent: :destroy

  def self.find_database(project, id)
    where(project_id: project.id, identifier: id).first || where(project_id: project.id, id: id).first
  end

  def to_param
    identifier
  end

  def save_with(vm)
    if self.persisted?
      self.update_attributes(vm.params_with(:identifier, :dbms_product_id, :summary, :comment, :lock_version))
    else
      self.attributes = vm.params_with(:identifier, :dbms_product_id, :summary, :comment)
      self.save
    end
  end
end
