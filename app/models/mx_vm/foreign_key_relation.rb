class MxVm::ForeignKeyRelatin
  include MxVm::VueModel

  attr_accessor :column_id, :ref_column_id, :position,
                :belonging_column_ids, :belonging_column_ids_in_ref_table,
                :valid_positions, :other_positions

  validates :column_id, presence: true, inclusion: { in: ->(record){ record.belonging_column_ids } }
  validates :ref_column_id, presence: true, inclusion: { in: ->(record){ record.belonging_column_ids_in_ref_table } }
  validates :position, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                       inclusion: { in: ->(record){ record.valid_positions }, message: :invalid },
                       exclusion: { in: ->(record){ record.other_positions }, message: :invalid }

  def initialize(params = {})
    simple_load_values!(params, :column_id, :ref_column_id, :position)
  end
end
