class MxVm::DataType
  include MxVm::VueModel

  def_attr :name, :sizable, :scalable, :position
  attr_accessor :using_names

  validates :name, presence: true,
                   length: { maximum: 255 },
                   exclusion: { in: ->(record){ record.using_names },
                                message: :duplicated,
                                if: 'name.present?' }

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxDataType)
      build_from_mx_data_type(params)
    end
  end

  def as_json_with_mx(options = {})
    as_json_without_mx(root: false, methods: [:errors])
  end
  alias_method_chain :as_json, :mx

  private

  def build_from_hash(params)
    simple_load_values_from_hash!(params, :id, :name, :position)
    [:sizable, :scalable].each { |sym| send("#{sym}=", params[sym].present?) }
  end

  def build_from_mx_data_type(data_type)
    simple_load_values_from_object!(data_type, :id, :name, :sizable, :scalable)
  end
end
