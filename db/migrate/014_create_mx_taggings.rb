class CreateMxTaggings < ActiveRecord::Migration
  def change
    create_table :mx_taggings do |t|
      t.timestamps

      t.integer :tag_id, null: false
      t.references :mx_taggable, polymorphic: true, null: false
    end

    add_index :mx_taggings, [:tag_id, :mx_taggable_type, :mx_taggable_id], unique: true, name: 'mx_taggings_uk1'
    add_index :mx_taggings, [:mx_taggable_type, :mx_taggable_id], unique: true, name: 'mx_taggings_uk2'
  end
end
