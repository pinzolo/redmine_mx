class MxVm::Database
  include MxVm::VueModel

  def_attr :identifier, :dbms_product_id, :summary, :comment, :lock_version

  validates :identifier, presence: true,
                         length: { maximum: 255 },
                         mx_db_absence: { class_name: 'MxDatabase' },
                         format: { with: /\A\w+\z/, if: 'identifier.present?' }
  validates :dbms_product_id, presence: true, mx_db_presence: { class_name: 'MxDbmsProduct', attribute: :id, if: 'dbms_product_id.present?' }
  validates :summary, length: { maximum: 255 }

  def initialize(params={})
    simple_load_values!(params, :id, :identifier, :dbms_product_id, :summary, :comment, :lock_version)
  end

  def as_json_with_mx(options = {})
    as_json_without_mx(root: false, methods: [:errors])
  end
  alias_method_chain :as_json, :mx
end

