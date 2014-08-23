class CreateMxPrimaryKeys < ActiveRecord::Migration
  def change
    create_table :mx_primary_keys do |t|
      t.timestamps

      t.integer :table_id, null: false
      t.string :name, null: false
    end

    add_index :mx_primary_keys, :table_id, unique: true, name: 'mx_primary_keys_uk1'
  end
end
