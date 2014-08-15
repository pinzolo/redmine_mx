require File.expand_path('../../test_helper', __FILE__)

class MxCommonColumnSetsControllerTest < ActionController::TestCase
  fixtures :users, :projects, :members, :roles, :member_roles,
    :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_common_column_sets, :mx_common_columns

  def setup
    enable_mx!
    setup_mx_permissions!
    @project = Project.find('ecookbook')
    @database = MxDatabase.find_database(@project, 'main')
    User.current = nil
  end

  def test_index_by_manager
    by_manager
    get :index, project_id: @project, database_id: @database
    assert_response :success
    assert_template 'index'
    database = assigns(:database)
    assert_equal 2, database.common_column_sets.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_common_column_set_path(@project, @database, 1) }
    assert_tag tag: 'a', attributes: { href: project_mx_database_common_column_set_path(@project, @database, 2) }
    assert_tag tag: 'a', attributes: { href: new_project_mx_database_common_column_set_path(@project, @database) }
  end

  def test_index_by_viewer
    by_viewer
    get :index, project_id: @project, database_id: @database
    assert_response :success
    assert_template 'index'
    database = assigns(:database)
    assert_equal 2, database.common_column_sets.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_common_column_set_path(@project, @database, 1) }
    assert_tag tag: 'a', attributes: { href: project_mx_database_common_column_set_path(@project, @database, 2) }
    assert_no_tag tag: 'a', attributes: { href: new_project_mx_database_common_column_set_path(@project, @database) }
  end

  def test_index_by_not_member
    by_not_member
    get :index, project_id: @project, database_id: @database
    assert_response 403
  end

  def test_index_with_invalid_project
    by_manager
    get :index, project_id: 'invalid', database_id: @database
    assert_response 404
  end

  def test_index_with_invalid_database
    by_manager
    get :index, project_id: @project, database_id: 'invalid'
    assert_response 404
  end
end
