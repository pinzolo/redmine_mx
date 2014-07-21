class CreateMxCommonColumns < ActiveRecord::Migration
  def change
    create_table :mx_common_columns do |t|
      t.timestamps

      t.integer :common_column_set_id, null: false
      t.string :type, null: false
      t.string :physical_name, null: false
      t.string :logical_name
      t.integer :data_type_id, null: false
      t.integer :size
      t.integer :scale
      t.boolean :nullable, null: false, default: false
      t.string :default_value
      t.integer :position, null: false
    end

    add_index :mx_common_columns, [:common_column_set_id, :physical_name], unique: true, name: 'mx_common_columns_uk1'
    add_index :mx_common_columns, [:common_column_set_id, :type, :position], unique: true, name: 'mx_columns_uk2'
  end
end
