class MxDbmsProduct < ActiveRecord::Base
  include MxCommentable
  unloadable

  has_many :data_types, class_name: 'MxDataType', foreign_key: :dbms_product_id, order: :name, dependent: :destroy

  PRODUCT_TYPES = { 'postgresql' => 'PostgreSQL', 'mysql' => 'MySQL', 'oracle' => 'Oracle', 'sql_server' => 'SQL Server', 'other' => 'Other'}.freeze

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
end
