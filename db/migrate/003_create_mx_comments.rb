class CreateMxComments < ActiveRecord::Migration
  def change
    create_table :mx_comments do |t|
      t.timestamps

      t.integer :comment_owner_id, null: false
      t.string :comment_owner_type, null: false
      t.text :comment
    end

    add_index :mx_comments, [:comment_owner_type, :comment_owner_id], unique: true, name: 'mx_comments_uk1'
  end
end
