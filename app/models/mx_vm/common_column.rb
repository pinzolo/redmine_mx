class MxVm::CommonColumn
  include MxVm::VueModel

  attr_accessor :type, :physical_name, :logical_name, :data_type_id,
    :size, :scale, :nullable, :default_value, :position, :comment

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxCommonColumn)
      build_from_mx_common_column(params)
    end
  end

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :type, :physical_name, :logical_name, :data_type_id,
                                  :size, :scale, :default_value, :position, :comment)
    send('nullable=', params[:nullable].present?)
  end

  def build_from_mx_common_column(mx_common_column)
    simple_load_values_from_object!(mx_common_column, :id, :type, :physical_name, :logical_name, :data_type_id,
                                    :size, :scale, :nullable, :default_value, :position, :comment)
  end
end
