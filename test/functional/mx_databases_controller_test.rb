require File.expand_path('../../test_helper', __FILE__)

class MxDatabasesControllerTest < ActionController::TestCase
  fixtures :users, :projects, :members, :roles, :member_roles,
    :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases

  def setup
    enable_mx!
    setup_mx_permissions!
    @project = Project.find('ecookbook')
    User.current = nil
  end

  def test_index_by_manager
    by_manager
    get :index, project_id: 'ecookbook'
    assert_response :success
    assert_template 'index'
    databases = assigns(:databases)
    assert_equal 2, databases.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_tables_path(@project, 'main') }
    assert_tag tag: 'a', attributes: { href: project_mx_database_tables_path(@project, 'sub') }
    assert_tag tag: 'a', attributes: { href: new_project_mx_database_path(@project) }
    assert_tag tag: 'a', attributes: { href: edit_project_mx_database_path(@project, 'main') }
    assert_tag tag: 'a', attributes: { href: project_mx_database_path(@project, 'main') }
    assert_tag tag: 'a', attributes: { href: edit_project_mx_database_path(@project, 'sub') }
    assert_tag tag: 'a', attributes: { href: project_mx_database_path(@project, 'sub') }
  end

  def test_index_by_viewer
    by_viewer
    get :index, project_id: 'ecookbook'
    assert_response :success
    assert_template 'index'
    databases = assigns(:databases)
    assert_equal 2, databases.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_tables_path(@project, 'main') }
    assert_tag tag: 'a', attributes: { href: project_mx_database_tables_path(@project, 'sub') }
    assert_no_tag tag: 'a', attributes: { href: new_project_mx_database_path(@project) }
    assert_no_tag tag: 'a', attributes: { href: edit_project_mx_database_path(@project, 'main') }
    assert_no_tag tag: 'a', attributes: { href: project_mx_database_path(@project, 'main') }
    assert_no_tag tag: 'a', attributes: { href: edit_project_mx_database_path(@project, 'sub') }
    assert_no_tag tag: 'a', attributes: { href: project_mx_database_path(@project, 'sub') }
  end

  def test_index_by_not_member
    by_not_member
    get :index, project_id: 'ecookbook'
    assert_response 403
  end

  def test_show_by_manager
    by_manager
    get :show, project_id: 'ecookbook', id: 'main'
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, 'main')
  end

  def test_show_by_viewer
    by_viewer
    get :show, project_id: 'ecookbook', id: 'main'
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, 'main')
  end

  def test_show_by_not_member
    by_not_member
    get :show, project_id: 'ecookbook', id: 'main'
    assert_response 403
  end
end
