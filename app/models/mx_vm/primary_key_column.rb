class MxVm::PrimaryKeyColumn
  include MxVm::VueModel

  attr_accessor :column_id, :position

  def initialize(params={})
    simple_load_values!(params, :column_id, :position)
  end
end

