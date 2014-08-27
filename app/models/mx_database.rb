class MxDatabase < ActiveRecord::Base
  include MxCommentable
  unloadable

  belongs_to :project
  belongs_to :dbms_product, class_name: 'MxDbmsProduct'
  has_many :tables, class_name: 'MxTable',
                    foreign_key: :database_id,
                    order: :physical_name,
                    include: :mx_comment,
                    dependent: :destroy
  has_many :column_sets, class_name: 'MxColumnSet',
                         foreign_key: :database_id,
                         order: :name,
                         include: :mx_comment,
                         dependent: :destroy

  def self.find_database(project, id)
    database = where(project_id: project.id, identifier: id).first || where(project_id: project.id, id: id).first
    raise ActiveRecord::RecordNotFound unless database
    database
  end

  def to_param
    identifier
  end

  def save_with(vm)
    if persisted?
      update_attributes(vm.params_with(:identifier, :dbms_product_id, :summary, :comment, :lock_version))
    else
      self.attributes = vm.params_with(:identifier, :dbms_product_id, :summary, :comment)
      save
    end
  end
end
