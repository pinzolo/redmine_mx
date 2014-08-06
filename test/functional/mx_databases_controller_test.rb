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
    get :index, project_id: @project
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
    get :index, project_id: @project
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
    get :index, project_id: @project
    assert_response 403
  end

  def test_show_by_manager
    by_manager
    get :show, project_id: @project, id: 'main'
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, 'main')
  end

  def test_show_by_viewer
    by_viewer
    get :show, project_id: @project, id: 'main'
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, 'main')
  end

  def test_show_by_not_member
    by_not_member
    get :show, project_id: @project, id: 'main'
    assert_response 403
  end

  def test_new_by_manager
    by_manager
    get :new, project_id: @project
    assert_response :success
    assert_template 'new'
    assert assigns(:vue_model)
  end

  def test_new_by_viewer
    by_viewer
    get :new, project_id: @project
    assert_response 403
  end

  def test_new_by_not_member
    by_not_member
    get :new, project_id: @project
    assert_response 403
  end

  #TODO: create

  def test_edit_by_manager
    by_manager
    get :edit, project_id: @project, id: 'main'
    assert_response :success
    assert_template 'edit'
    database = assigns(:database)
    assert database
    assert_equal 1, database.id
    assert_equal 'main', database.identifier
    vm = assigns(:vue_model)
    assert vm
    assert_equal database.identifier, vm.identifier
    assert_equal database.dbms_product_id, vm.dbms_product_id
    assert_equal database.summary, vm.summary
    assert_equal database.comment, vm.comment
  end

  def test_edit_by_viewer
    by_viewer
    get :edit, project_id: @project, id: 'main'
    assert_response 403
  end

  def test_edit_by_not_member
    by_not_member
    get :edit, project_id: @project, id: 'main'
    assert_response 403
  end

  #TODO: update

  def test_destroy_by_manager
    by_manager
    assert_difference 'MxDatabase.count', -1 do
      delete :destroy, project_id: @project, id: 'main'
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert !MxDatabase.where(identifier: 'main').exists?
  end

  def test_destroy_by_viewer
    by_viewer
    assert_no_difference 'MxDatabase.count' do
      delete :destroy, project_id: @project, id: 'main'
    end
    assert_response 403
  end

  def test_destroy_by_not_member
    by_not_member
    assert_no_difference 'MxDatabase.count' do
      delete :destroy, project_id: @project, id: 'main'
    end
    assert_response 403
  end
end
