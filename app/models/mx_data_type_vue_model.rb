class MxDataTypeVueModel
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attr_accessor :id, :name, :sizable, :scalable, :use_by_default

  def initialize(params={})
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxDataType)
      build_from_mx_data_type(params)
    end
  end

  def persisted?
    false
  end

  private

  def build_from_hash(params)
    [:id, :name].each { |sym| send("#{sym}=", params[sym]) }
    [:sizable, :scalable, :use_by_default].each { |sym| send("#{sym}=", params[sym].present?) }
  end

  def build_from_mx_data_type(data_type)
    [:id, :name, :sizable, :scalable, :use_by_default].each { |sym| send("#{sym}=", data_type.send(sym)) }
  end
end
