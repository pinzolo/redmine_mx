class CreateMxCommonColumnSets < ActiveRecord::Migration
  def change
    create_table :mx_common_column_sets do |t|
      t.timestamps
      t.integer :lock_version, null: false, default: 0

      t.integer :table_list_id, null: false
      t.string :name, null: false
    end

    add_index :mx_common_column_sets, [:table_list_id, :name], unique: true, name: 'mx_common_column_sets_uk1'
  end
end
