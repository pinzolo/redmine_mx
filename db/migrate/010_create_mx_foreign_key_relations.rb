class CreateMxForeignKeyRelations < ActiveRecord::Migration
  def change
    create_table :mx_foreign_key_relations do |t|
      t.timestamps

      t.integer :foreign_key_id, null: false
      t.integer :source_column_id, null: false
      t.integer :referred_column_id, null: false
    end

    add_index :mx_foreign_key_relations, [:foreign_key_id, :source_column_id, :referred_column_id], unique: true, name: 'mx_foreign_key_relations_uk1'
  end
end
