class CreateMxIndices < ActiveRecord::Migration
  def change
    create_table :mx_indices do |t|
      t.timestamps

      t.integer :table_id, null: false
      t.string :name, null: false
      t.boolean :unique, null: false, default: false
    end

    add_index :mx_indices, [:table_id, :name], unique: true, name: 'mx_indices_uk1'
  end
end
