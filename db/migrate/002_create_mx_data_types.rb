class CreateMxDataTypes < ActiveRecord::Migration
  def change
    create_table :mx_data_types do |t|
      t.timestamps

      t.string :name, null: false
      t.integer :dbms_product_id, null: false
      t.boolean :sizable, null: false, default: true
      t.boolean :scalable, null: false, default: false
    end

    add_index :mx_data_types, [:dbms_product_id, :name], unique: true, name: 'mx_data_types_uk1'
  end
end
