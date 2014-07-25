class MxDbmsProduct < ActiveRecord::Base
  unloadable

  has_many :data_types, class_name: 'MxDataType', foreign_key: :dbms_product_id, order: :name, dependent: :destroy
end
