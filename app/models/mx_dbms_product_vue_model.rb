class MxDbmsProductVueModel
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attr_accessor :name, :type, :comment, :data_types

  def initialize(params={})
    self.data_types = []
    if params.is_a?(Hash)
      build_from_hash(params)
    elsif params.is_a?(MxDbmsProduct)
      build_from_mx_dbms_product(params)
    end
  end

  def persisted?
    false
  end

  private

  def build_from_hash(params)
    [:name, :type, :comment].each { |sym| send("#{sym}=", params[sym]) }
    if params[:data_types]
      self.data_types = params[:data_types].values.map { |data_type_params| MxDataTypeVueModel.new(data_type_params) }.sort_by(&:name)
    end
  end

  def build_from_mx_dbms_product(dbms_product)
    [:name, :type, :comment].each { |sym| send("#{sym}=", dbms_product.send(sym)) }
    self.data_types = dbms_product.data_types.map { |data_type| MxDataTypeVueModel.new(data_type) }
  end
end
