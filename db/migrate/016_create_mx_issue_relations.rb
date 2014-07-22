class CreateMxIssueRelations < ActiveRecord::Migration
  def change
    create_table :mx_issue_relations do |t|
      t.timestamps

      t.references :mx_issue_relatable, polymorphic: true, null: false
      t.integer :issue_id, null: false
    end

    add_index :mx_taggings, :issue_id
    add_index :mx_taggings, [:mx_issue_relatable_type, :mx_issue_relatable_id, :issue_id], unique: true, name: 'mx_issue_relations_uk1'
  end
end
