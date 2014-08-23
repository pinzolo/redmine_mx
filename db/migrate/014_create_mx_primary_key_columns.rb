class CreateMxPrimaryKeyColumns < ActiveRecord::Migration
  def change
    create_table :mx_primary_key_columns do |t|
      t.timestamps

      t.integer :primary_key_id, null: false
      t.integer :column_id, null: false
      t.integer :position, null: false
    end

    add_index :mx_primary_key_columns, :column_id
    add_index :mx_primary_key_columns, [:primary_key_id, :column_id], unique: true, name: 'mx_primary_key_columns_uk1'
  end
end
