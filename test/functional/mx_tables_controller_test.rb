require File.expand_path('../../test_helper', __FILE__)

class MxTablesControllerTest < ActionController::TestCase
  fixtures :users, :projects, :members, :roles, :member_roles,
    :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_column_sets, :mx_columns, :mx_tables

  def setup
    enable_mx!
    setup_mx_permissions!
    @project = Project.find('ecookbook')
    @database = MxDatabase.find_database(@project, 'main')
    by_manager
  end

  # new {{{

  def test_new_by_manager
    get :new, project_id: @project, database_id: @database
    assert_response :success
    assert_template 'new'
    assert assigns(:vue_model)
  end

  def test_new_by_viewer
    by_viewer
    get :new, project_id: @project, database_id: @database
    assert_response 403
  end

  def test_new_by_not_member
    by_not_member
    get :new, project_id: @project, database_id: @database
    assert_response 403
  end

  def test_new_with_invalid_project
    get :new, project_id: 'invalid', database_id: @database
    assert_response 404
  end

  def test_new_with_invalid_database
    get :new, project_id: @project, database_id: 'invalid'
    assert_response 404
  end

  # }}}
end
