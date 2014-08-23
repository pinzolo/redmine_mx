class CreateMxForeignKeys < ActiveRecord::Migration
  def change
    create_table :mx_foreign_keys do |t|
      t.timestamps

      t.integer :table_id, null: false
      t.integer :ref_table_id, null: false
      t.string :name, null: false
    end

    add_index :mx_foreign_keys, [:table_id, :name], unique: true, name: 'mx_foreign_keys_uk1'
  end
end
