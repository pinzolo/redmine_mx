class MxVm::DataType
  include MxVm::VueModel

  attr_accessor :name, :sizable, :scalable, :use_by_default, :position

  validates :name, presence: true, length: { maximum: 200 }

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxDataType)
      build_from_mx_data_type(params)
    end
  end

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :position)
    [:sizable, :scalable, :use_by_default].each { |sym| send("#{sym}=", params[sym].present?) }
  end

  def build_from_mx_data_type(data_type)
    simple_load_values_from_object!(data_type, :id, :name, :sizable, :scalable, :use_by_default)
  end
end
