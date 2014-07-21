class CreateMxTags < ActiveRecord::Migration
  def change
    create_table :mx_tags do |t|
      t.timestamps

      t.string :name, null: false
    end
  end
end
