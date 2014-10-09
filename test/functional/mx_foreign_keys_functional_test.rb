require File.expand_path('../../test_helper', __FILE__)

class MxForeignKeysFunctionalTest < ActionController::TestCase
  tests MxTablesController
  fixtures :users, :projects, :members, :roles, :member_roles,
           :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_column_sets, :mx_columns, :mx_tables,
           :mx_primary_keys, :mx_primary_key_columns, :mx_indices, :mx_index_columns, :mx_foreign_keys, :mx_foreign_key_relations

  def setup
    enable_mx!
    setup_mx_permissions!
    @project = Project.find('ecookbook')
    @database = MxDatabase.find_database(@project, 'main')
    by_manager
  end

  def test_destroy
    foreign_key_ids = MxForeignKey.where(table_id: 4).map(&:id)
    assert_difference 'MxForeignKey.count', -2 do
      assert_difference 'MxForeignKeyRelation.count', -2 do
        delete :destroy, project_id: @project, database_id: @database, id: 4
      end
    end
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, @database)
    assert MxForeignKey.where(table_id: 4).empty?
    assert MxForeignKeyRelation.where(foreign_key_id: foreign_key_ids).empty?
  end
end
