class CreateMxTaggings < ActiveRecord::Migration
  def change
    create_table :mx_taggings do |t|
      t.timestamps

      t.references :mx_taggable, polymorphic: true, null: false
      t.integer :tag_id, null: false
    end

    add_index :mx_taggings, :tag_id
    add_index :mx_taggings, [:mx_taggable_type, :mx_taggable_id, :tag_id], unique: true, name: 'mx_taggings_uk1'
  end
end
