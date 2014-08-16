class MxVm::Column
  include MxVm::VueModel

  attr_accessor :physical_name, :logical_name, :data_type_id,
    :size, :scale, :nullable, :default_value, :position, :comment

  validates :physical_name, presence: true, length: { maximum: 200 }
  validates :logical_name, length: { maximum: 200 }
  validates :data_type_id, presence: true
  validates :size, numericality: { only_integer: true, greater_than: 0, if: 'size.present?' }
  validates :scale, numericality: { only_integer: true, greater_than: 0, if: 'scale.present?' }
  validates :default_value, length: { maximum: 200 }

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxColumn)
      build_from_mx_column(params)
    end
  end

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
