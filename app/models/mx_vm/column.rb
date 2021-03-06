class MxVm::Column
  include MxVm::VueModel

  def_attr :physical_name, :logical_name, :data_type_id, :size, :scale, :nullable, :default_value, :position, :comment
  attr_accessor :data_type_ids, :using_physical_names

  validates :physical_name, presence: true,
                            length: { maximum: 255 },
                            exclusion: { in: ->(record){ record.using_physical_names },
                                         message: :duplicated,
                                         if: 'physical_name.present?' }
  validates :logical_name, length: { maximum: 255 }
  validates :data_type_id, presence: true,
                           inclusion: { in: ->(record){ record.data_type_ids },
                                        if: 'data_type_id.present?' }
  validates :size, numericality: { only_integer: true, greater_than: 0, if: 'size.present?' }
  validates :scale, numericality: { only_integer: true, greater_than: 0, if: 'scale.present?' }
  validates :default_value, length: { maximum: 255 }

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxColumn)
      build_from_mx_column(params)
    end
  end

  def as_json_with_mx(options = {})
    as_json_without_mx(root: false, methods: [:errors])
  end
  alias_method_chain :as_json, :mx

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :physical_name, :logical_name, :data_type_id,
                                  :size, :scale, :default_value, :position, :comment)
    send('nullable=', params[:nullable].present?)
  end

  def build_from_mx_column(mx_column)
    simple_load_values_from_object!(mx_column, :id, :physical_name, :logical_name, :data_type_id,
                                    :size, :scale, :nullable, :default_value, :position, :comment)
  end
end
