class CreateMxTableVersions < ActiveRecord::Migration
  def change
    create_table :mx_table_versions do |t|
      t.timestamps

      t.integer :table_id, null: false
      t.integer :version, null: false
      t.text :snapshot, null: false
      t.text :change_summary
    end

    add_index :mx_table_versions, [:table_id, :version], unique: true, name: 'mx_table_versions_uk1'
  end
end
