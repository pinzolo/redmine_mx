class CreateMxTables < ActiveRecord::Migration
  def change
    create_table :mx_tables do |t|
      t.timestamps
      t.integer :lock_version, null: false, default: 0

      t.integer :project_id, null: false
      t.integer :table_list_id, null: false
      t.string :physical_name, null: false
      t.string :logical_name
      t.integer :current_version, null: false, default: 1
    end

    add_index :mx_tables, :project_id
    add_index :mx_tables, [:table_list_id, :physical_name], unique: true, name: 'mx_tables_uk1'
  end
end
