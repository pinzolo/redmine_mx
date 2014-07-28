class CreateMxDbmsProducts < ActiveRecord::Migration
  def change
    create_table :mx_dbms_products do |t|
      t.timestamps
      t.integer :lock_version, null: false, default: 0

      t.string :name, null: false
      t.string :type, null: false
    end

    add_index :mx_dbms_products, :name, unique: true
    add_index :mx_dbms_products, :type
  end
end
