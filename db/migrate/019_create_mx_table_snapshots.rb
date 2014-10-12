class CreateMxTableSnapshots < ActiveRecord::Migration
  def change
    create_table :mx_table_snapshots do |t|
      t.timestamps

      t.integer :table_id, null: false
      t.integer :version, null: false
      t.text :table_data, null: false
      t.text :change_summary
    end

    add_index :mx_table_snapshots, [:table_id, :version], unique: true, name: 'mx_table_snapshots_uk1'
  end
end
