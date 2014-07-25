class CreateMxTableLists < ActiveRecord::Migration
  def change
    create_table :mx_table_lists do |t|
      t.timestamps
      t.integer :lock_version, null: false, default: 0

      t.integer :project_id, null: false
      t.integer :dbms_product_id, null: false
      t.string :identifier, null: false
      t.string :name
    end

    add_index :mx_table_lists, [:project_id, :identifier], unique: true, name: 'mx_table_lists_uk1'
  end
end
