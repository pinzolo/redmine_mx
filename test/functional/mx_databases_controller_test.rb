require File.expand_path('../../test_helper', __FILE__)

class MxDatabasesControllerTest < ActionController::TestCase
  fixtures :users, :projects, :members, :roles, :member_roles,
    :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_column_sets

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

  def test_index_with_invalid_project
    by_manager
    get :index, project_id: 'invalid'
    assert_response 404
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

  def test_show_with_invalid_project
    by_manager
    get :show, project_id: 'invalid', id: 'main'
    assert_response 404
  end

  def test_show_with_invalid_id
    by_manager
    get :show, project_id: @project, id: 'other'
    assert_response 404
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

  def test_new_with_invalid_project
    by_manager
    get :new, project_id: 'invalid'
    assert_response 404
  end

  def test_create_by_manager_with_valid_params
    by_manager
    assert_difference 'MxDatabase.count', 1 do
      post :create, project_id: @project, mx_vm_database: valid_create_params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(3, valid_create_params)
  end

  def test_create_by_viewer
    by_viewer
    assert_no_difference 'MxDatabase.count' do
      post :create, project_id: @project, mx_vm_database: valid_create_params
    end
    assert_response 403
  end

  def test_create_by_not_member
    by_not_member
    assert_no_difference 'MxDatabase.count' do
      post :create, project_id: @project, mx_vm_database: valid_create_params
    end
    assert_response 403
  end

  def test_create_with_invalid_project
    by_manager
    assert_no_difference 'MxDatabase.count' do
      post :create, project_id: 'invalid', mx_vm_database: valid_create_params
    end
    assert_response 404
  end

  def test_create_without_identifier
    assert_create_with_value_deleted_params(:identifier, "can't be blank")
  end

  def test_create_with_empty_identifier
    assert_create_with_value_overriden_params(:identifier, '', "can't be blank")
  end

  def test_create_with_too_long_identifier
    assert_create_with_value_overriden_params(:identifier, 'a' * 201)
    assert_match(/is too long/, assigns(:vue_model).errors[:identifier].first)
  end

  def test_create_with_just_long_identifier
    by_manager
    params = valid_create_params.tap { |p| p[:identifier] = 'a' * 200 }
    assert_difference 'MxDatabase.count', 1 do
      post :create, project_id: @project, mx_vm_database: params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(3, params)
  end

  def test_create_with_invalid_format_identifier
    assert_create_with_value_overriden_params(:identifier, 'a-b', 'is invalid')
  end

  def test_create_with_already_taken_identifier
    assert_create_with_value_overriden_params(:identifier, 'main', 'has already been taken')
  end

  def test_create_without_dbms_product_id
    assert_create_with_value_deleted_params(:dbms_product_id, "can't be blank")
  end

  def test_create_with_empty_dbms_product_id
    assert_create_with_value_overriden_params(:dbms_product_id, '', "can't be blank")
  end

  def test_create_with_invalid_dbms_product_id_that_not_in_mx_dbms_products
    assert_create_with_value_overriden_params(:dbms_product_id, 6, 'is invalid')
  end

  def test_create_without_summary
    by_manager
    params = valid_create_params.tap { |p| p.delete(:summary) }
    assert_difference 'MxDatabase.count', 1 do
      post :create, project_id: @project, mx_vm_database: params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(3, params)
  end

  def test_create_with_empty_summary
    by_manager
    params = valid_create_params.tap { |p| p[:summary] = '' }
    assert_difference 'MxDatabase.count', 1 do
      post :create, project_id: @project, mx_vm_database: params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(3, params)
  end

  def test_create_with_too_long_summary
    assert_create_with_value_overriden_params(:summary, 'a' * 201)
    assert_match(/is too long/, assigns(:vue_model).errors[:summary].first)
  end

  def test_create_with_just_long_summary
    by_manager
    params = valid_create_params.tap { |p| p[:summary] = 'a' * 200 }
    assert_difference 'MxDatabase.count', 1 do
      post :create, project_id: @project, mx_vm_database: params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(3, params)
  end

  def test_create_without_comment
    by_manager
    params = valid_create_params.tap { |p| p.delete(:comment) }
    assert_difference 'MxDatabase.count', 1 do
      post :create, project_id: @project, mx_vm_database: params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(3, params)
  end

  def test_create_with_empty_comment
    by_manager
    params = valid_create_params.tap { |p| p[:comment] = '' }
    assert_difference 'MxDatabase.count', 1 do
      post :create, project_id: @project, mx_vm_database: params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(3, params)
  end

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

  def test_edit_with_invalid_project
    by_manager
    get :edit, project_id: 'invalid', id: 'main'
    assert_response 404
  end

  def test_edit_with_invalid_id
    by_manager
    get :edit, project_id: @project, id: 'other'
    assert_response 404
  end

  def test_update_by_manager_with_valid_params
    by_manager
    assert_no_difference 'MxDatabase.count' do
      put :update, project_id: @project, id: 'sub', mx_vm_database: valid_update_params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(2, valid_update_params)
  end

  def test_update_by_viewer
    by_viewer
    assert_no_difference 'MxDatabase.count' do
      put :update, project_id: @project, id: 'sub', mx_vm_database: valid_update_params
    end
    assert_response 403
  end

  def test_update_by_not_member
    by_not_member
    assert_no_difference 'MxDatabase.count' do
      put :update, project_id: @project, id: 'sub', mx_vm_database: valid_update_params
    end
    assert_response 403
  end

  def test_update_with_invalid_project
    by_manager
    assert_no_difference 'MxDatabase.count' do
      put :update, project_id: 'invalid', id: 'sub', mx_vm_database: valid_update_params
    end
    assert_response 404
  end

  def test_update_with_invalid_id
    by_manager
    assert_no_difference 'MxDatabase.count' do
      put :update, project_id: @project, id: 'other', mx_vm_database: valid_update_params
    end
    assert_response 404
  end

  def test_update_without_identifier
    assert_update_with_value_deleted_params(:identifier, "can't be blank")
  end

  def test_update_with_empty_identifier
    assert_update_with_value_overriden_params(:identifier, '', "can't be blank")
  end

  def test_update_with_too_long_identifier
    assert_update_with_value_overriden_params(:identifier, 'a' * 201)
    assert_match(/is too long/, assigns(:vue_model).errors[:identifier].first)
  end

  def test_update_with_just_long_identifier
    by_manager
    params = valid_update_params.tap { |p| p[:identifier] = 'a' * 200 }
    assert_no_difference 'MxDatabase.count' do
      put :update, project_id: @project, id: 'sub', mx_vm_database: params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(2, params)
  end

  def test_update_with_invalid_format_identifier
    assert_update_with_value_overriden_params(:identifier, 'a-b', 'is invalid')
  end

  def test_update_with_already_taken_identifier
    assert_update_with_value_overriden_params(:identifier, 'main', 'has already been taken')
  end

  def test_update_without_dbms_product_id
    assert_update_with_value_deleted_params(:dbms_product_id, "can't be blank")
  end

  def test_update_with_empty_dbms_product_id
    assert_update_with_value_overriden_params(:dbms_product_id, '', "can't be blank")
  end

  def test_update_with_invalid_dbms_product_id_that_not_in_mx_dbms_products
    assert_update_with_value_overriden_params(:dbms_product_id, 6, 'is invalid')
  end

  def test_update_with_too_long_summary
    assert_update_with_value_overriden_params(:summary, 'a' * 201)
    assert_match(/is too long/, assigns(:vue_model).errors[:summary].first)
  end

  def test_update_with_just_long_summary
    by_manager
    params = valid_update_params.tap { |p| p[:summary] = 'a' * 200 }
    assert_no_difference 'MxDatabase.count' do
      put :update, project_id: @project, id: 'sub', mx_vm_database: params
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert_saved_database(2, params)
  end

  def test_update_with_invalid_lock_version
    assert_update_with_value_overriden_params(:lock_version, '1')
    assert_conflict_flash
  end

  def test_destroy_by_manager
    by_manager
    assert_difference 'MxDatabase.count', -1 do
      delete :destroy, project_id: @project, id: 'main'
    end
    assert_response 302
    assert_redirected_to project_mx_databases_path(@project)
    assert MxDatabase.where(identifier: 'main').empty?
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

  def test_destroy_should_delete_mx_column_sets
    by_manager
    assert_difference 'MxColumnSet.count', -2 do
      delete :destroy, project_id: @project, id: 'main'
    end
    assert MxColumnSet.where(database_id: 1).empty?
  end

  def test_destroy_with_invalid_project
    by_manager
    assert_no_difference 'MxDatabase.count' do
      delete :destroy, project_id: 'invalid', id: 'main'
    end
    assert_response 404
  end

  def test_destroy_with_invalid_id
    by_manager
    assert_no_difference 'MxDatabase.count' do
      delete :destroy, project_id: 'invalid', id: 'other'
    end
    assert_response 404
  end

  private

  def valid_create_params
    {
      identifier: 'test',
      dbms_product_id: 1,
      summary: 'summary',
      comment: "foo\nbar\nbaz"
    }
  end

  def valid_update_params
    valid_create_params.merge(lock_version: '0')
  end

  def assert_create_with_value_deleted_params(attribute, error=nil)
    by_manager
    params = valid_create_params.tap { |p| p.delete(attribute) }
    assert_no_difference 'MxDatabase.count' do
      post :create, project_id: @project, mx_vm_database: params
    end
    assert_response :success
    assert_template 'new'
  end

  def assert_create_with_value_overriden_params(attribute, invalid_value, error=nil)
    by_manager
    params = valid_create_params.tap { |p| p[attribute] = invalid_value }
    assert_no_difference 'MxDatabase.count' do
      post :create, project_id: @project, mx_vm_database: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal error, assigns(:vue_model).errors[attribute].first if error
  end

  def assert_update_with_value_deleted_params(attribute, error=nil)
    by_manager
    params = valid_create_params.tap { |p| p.delete(attribute) }
    assert_no_difference 'MxDatabase.count' do
      put :update, project_id: @project, id: 'sub', mx_vm_database: params
    end
    assert_response :success
    assert_template 'edit'
  end

  def assert_update_with_value_overriden_params(attribute, invalid_value, error=nil)
    by_manager
    params = valid_create_params.tap { |p| p[attribute] = invalid_value }
    assert_no_difference 'MxDatabase.count' do
      put :update, project_id: @project, id: 'sub', mx_vm_database: params
    end
    assert_response :success
    assert_template 'edit'
    assert_equal error, assigns(:vue_model).errors[attribute].first if error
  end

  def assert_saved_database(id, params)
    database = MxDatabase.find(id)
    assert_equal params[:identifier], database.identifier
    assert_equal params[:dbms_product_id].to_i, database.dbms_product_id
    assert_equal params[:summary], database.summary
    assert_equal params[:comment].presence, database.comment
  end
end
