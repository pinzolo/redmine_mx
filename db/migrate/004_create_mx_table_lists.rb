class CreateMxTableLists < ActiveRecord::Migration
  def change
    create_table :mx_table_lists do |t|
      t.timestamps
      t.integer :lock_version, null: false, default: 0

      t.integer :project_id, null: false
      t.integer :database_id, null: false
      t.string :name, null: false
    end

    add_index :mx_table_lists, [:project_id, :name], unique: true, name: 'mx_table_lists_uk1'
  end
end
