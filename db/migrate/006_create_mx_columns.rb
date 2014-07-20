class CreateMxColumns < ActiveRecord::Migration
  def change
    create_table :mx_columns do |t|
      t.timestamps

      t.integer :table_id, null: false
      t.string :physical_name, null: false
      t.string :logical_name
      t.integer :data_type_id, null: false
      t.integer :size
      t.integer :scale
      t.boolean :nullable, null: false, default: false
      t.string :default_value
      t.integer :position, null: false
    end

    add_index :mx_columns, [:table_id, :physical_name], unique: true, name: 'mx_columns_uk1'
  end
end
