require File.expand_path('../../test_helper', __FILE__)

class MxIndicesFunctionalTest < ActionController::TestCase
  tests MxTablesController
  fixtures :users, :projects, :members, :roles, :member_roles,
    :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_column_sets, :mx_columns, :mx_tables,
    :mx_primary_keys, :mx_primary_key_columns, :mx_indices, :mx_index_columns

  def setup
    enable_mx!
    setup_mx_permissions!
    @project = Project.find('ecookbook')
    @database = MxDatabase.find_database(@project, 'main')
    by_manager
  end

  def test_destroy
    index_ids = MxIndex.where(table_id: 1).map(&:id)
    assert_difference 'MxIndex.count', -2 do
      assert_difference 'MxIndexColumn.count', -3 do
        delete :destroy, project_id: @project, database_id: @database, id: 1
      end
    end
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, @database)
    assert MxIndex.where(table_id: 1).empty?
    assert MxIndexColumn.where(index_id: index_ids).empty?
  end
end
