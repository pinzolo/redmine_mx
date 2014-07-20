class CreateMxDataTypes < ActiveRecord::Migration
  def change
    create_table :mx_data_types do |t|
      t.integer :lock_version, null: false
      t.timestamps

      t.string :name, null: false
      t.integer :database_id, null: false
      t.boolean :sizable, null: false, default: true
      t.boolean :scalable, null: false, default: false
      t.boolean :default_use, null: false, default: false
    end

    add_index :mx_data_types, [:database_id, :name], unique: true, name: 'mx_data_types_uk1'
  end
end
