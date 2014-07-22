class CreateMxTags < ActiveRecord::Migration
  def change
    create_table :mx_tags do |t|
      t.timestamps

      t.string :name, null: false
    end

    add_index :mx_tags, :name, unique: true
  end
end
