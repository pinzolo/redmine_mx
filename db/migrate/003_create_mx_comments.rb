class CreateMxComments < ActiveRecord::Migration
  def change
    create_table :mx_comments do |t|
      t.timestamps

      t.integer :mx_commentable_id, null: false
      t.string :mx_commentable_type, null: false
      t.text :comment
    end

    add_index :mx_comments, [:mx_commentable_type, :mx_commentable_id], unique: true, name: 'mx_comments_uk1'
  end
end
