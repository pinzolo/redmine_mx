class CreateMxIndexColumns < ActiveRecord::Migration
  def change
    create_table :mx_index_columns do |t|
      t.timestamps

      t.integer :index_id, null: false
      t.integer :column_id, null: false
      t.integer :position, null: false
    end

    add_index :mx_index_columns, :column_id
    add_index :mx_index_columns, [:index_id, :column_id], unique: true, name: 'mx_index_columns_uk1'
    add_index :mx_index_columns, [:index_id, :position], unique: true, name: 'mx_index_columns_uk2'
  end
end
