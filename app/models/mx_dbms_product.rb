class MxDbmsProduct < ActiveRecord::Base
  include MxCommentable
  unloadable

  has_many :data_types, class_name: 'MxDataType', foreign_key: :dbms_product_id, order: :name, dependent: :destroy

  PRODUCT_TYPES = { 'postgresql' => 'PostgreSQL', 'mysql' => 'MySQL', 'oracle' => 'Oracle', 'sql_server' => 'SQL Server', 'other' => 'Other'}.freeze
  PRODUCT_CLASSES = { 'postgresql' => MxDbms::Postgresql, 'mysql' => MxDbms::Mysql, 'oracle' => MxDbms::Oracle, 'sql_server' => MxDbms::SqlServer, 'other' => MxDbms::Other}.freeze

  class << self
    def find_sti_class(type_name)
      "MxDbms::#{type_name.camelize}".constantize
    end

    def sti_name
      name.underscore.split('/').last
    end
  end

  def type_name
    PRODUCT_TYPES[type]
  end

  def save_with!(vm)
    ActiveRecord::Base.transaction do
      self.attributes = vm.params_with(:name, :comment)
      self.save!
      vm.data_types.each do |data_type|
        self.data_types.build(data_type.params_with(:name, :sizable, :scalable, :use_by_default)).save!
      end
    end
  end
end
