class CreateMxTables < ActiveRecord::Migration
  def change
    create_table :mx_tables do |t|
      t.timestamps
      t.integer :lock_version, null: false, default: 0

      t.integer :project_id, null: false
      t.integer :database_id, null: false
      t.integer :column_set_id
      t.string :physical_name, null: false
      t.string :logical_name
      t.integer :current_version, null: false, default: 1
      t.integer :created_user_id
      t.integer :updated_user_id
    end

    add_index :mx_tables, :project_id
    add_index :mx_tables, [:database_id, :physical_name], unique: true, name: 'mx_tables_uk1'
  end
end
