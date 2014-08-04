class MxVm::Database
  include MxVm::VueModel

  attr_accessor :identifier, :dbms_product_id, :summary, :comment, :lock_version

  validates :identifier, presence: true, length: { maximum: 200 }
  validates :dbms_product_id, presence: true, mx_db_presence: { class_name: 'MxDbmsProduct', attribute: :id, if: 'dbms_product_id.present?' }
  validates :summary, length: { maximum: 200 }

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxDatabase)
      build_from_mx_database(params)
    end
  end

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :identifier, :dbms_product_id, :summary, :comment, :lock_version)
  end

  def build_from_mx_database(database)
    simple_load_values_from_object!(database, :id, :identifier, :dbms_product_id, :summary, :comment, :lock_version)
  end
end

