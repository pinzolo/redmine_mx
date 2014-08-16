class CreateMxColumnSets < ActiveRecord::Migration
  def change
    create_table :mx_column_sets do |t|
      t.timestamps
      t.integer :lock_version, null: false, default: 0

      t.integer :database_id, null: false
      t.string :name, null: false
    end

    add_index :mx_column_sets, [:database_id, :name], unique: true, name: 'mx_column_sets_uk1'
  end
end
