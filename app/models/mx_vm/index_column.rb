class MxVm::IndexColumn
  include MxVm::VueModel

  def_attr :column_id, :position
  attr_accessor :belonging_column_ids, :valid_positions, :other_positions

  validates :column_id, presence: true, inclusion: { in: ->(record){ record.belonging_column_ids } }
  validates :position, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                       inclusion: { in: ->(record){ record.valid_positions }, message: :invalid },
                       exclusion: { in: ->(record){ record.other_positions }, message: :invalid }

  def initialize(params={})
    simple_load_values!(params, :column_id, :position)
  end

  def as_json_with_mx(options = {})
    as_json_without_mx(root: false, methods: [:errors])
  end
  alias_method_chain :as_json, :mx
end

