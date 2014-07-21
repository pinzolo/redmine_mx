class CreateMxTaggings < ActiveRecord::Migration
  def change
    create_table :mx_taggings do |t|
      t.timestamps

      t.integer :tag_id, null: false
      t.integer :mx_tag_owner_id, null: false
      t.string :mx_tag_owner_type, null: false
    end

    add_index :mx_taggings, [:tag_id, :mx_tag_owner_type, :mx_tag_owner_id], unique: true, name: 'mx_taggings_uk1'
    add_index :mx_taggings, [:mx_tag_owner_type, :mx_tag_owner_id], unique: true, name: 'mx_taggings_uk2'
  end
end
