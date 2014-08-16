require File.expand_path('../../test_helper', __FILE__)

class MxColumnSetsControllerTest < ActionController::TestCase
  fixtures :users, :projects, :members, :roles, :member_roles,
    :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_column_sets, :mx_columns

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
    assert_equal 2, database.column_sets.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_column_set_path(@project, @database, 1) }
    assert_tag tag: 'a', attributes: { href: project_mx_database_column_set_path(@project, @database, 2) }
    assert_tag tag: 'a', attributes: { href: new_project_mx_database_column_set_path(@project, @database) }
  end

  def test_index_by_viewer
    by_viewer
    get :index, project_id: @project, database_id: @database
    assert_response :success
    assert_template 'index'
    database = assigns(:database)
    assert_equal 2, database.column_sets.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_column_set_path(@project, @database, 1) }
    assert_tag tag: 'a', attributes: { href: project_mx_database_column_set_path(@project, @database, 2) }
    assert_no_tag tag: 'a', attributes: { href: new_project_mx_database_column_set_path(@project, @database) }
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

  def test_show_by_manager
    by_manager
    get :show, project_id: @project, database_id: @database, id: 1
    assert_response :success
    assert_template 'show'
    column_set = assigns(:column_set)
    assert column_set
    assert_equal 'default', column_set.name
    assert_equal 5, column_set.columns.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_column_sets_path(@project, @database) }
    assert_tag tag: 'a', attributes: { href: edit_project_mx_database_column_set_path(@project, @database, column_set) }
    assert_tag tag: 'a', attributes: { href: project_mx_database_column_set_path(@project, @database, column_set) }
  end

  def test_show_by_viewer
    by_viewer
    get :show, project_id: @project, database_id: @database, id: 1
    assert_response :success
    assert_template 'show'
    column_set = assigns(:column_set)
    assert column_set
    assert_equal 'default', column_set.name
    assert_equal 5, column_set.columns.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_column_sets_path(@project, @database) }
    assert_no_tag tag: 'a', attributes: { href: edit_project_mx_database_column_set_path(@project, @database, column_set) }
    assert_no_tag tag: 'a', attributes: { href: project_mx_database_column_set_path(@project, @database, column_set) }
  end

  def test_show_by_not_member
    by_not_member
    get :show, project_id: @project, database_id: @database, id: 1
    assert_response 403
  end

  def test_show_with_invalid_project
    by_manager
    get :show, project_id: 'invalid', database_id: @database, id: 1
    assert_response 404
  end

  def test_show_with_invalid_database
    by_manager
    get :show, project_id: @project, database_id: 'invalid', id: 1
    assert_response 404
  end

  def test_show_with_invalid_id
    by_manager
    get :show, project_id: @project, database_id: @database, id: -1
    assert_response 404
  end

  def test_new_by_manager
    by_manager
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
    by_manager
    get :new, project_id: 'invalid', database_id: @database
    assert_response 404
  end

  def test_new_with_invalid_database
    by_manager
    get :new, project_id: @project, database_id: 'invalid'
    assert_response 404
  end

  #TODO: create

  def test_edit_by_manager
    by_manager
    get :edit, project_id: @project, database_id: @database, id: 1
    assert_response :success
    assert_template 'edit'
    column_set = assigns(:column_set)
    assert column_set
    assert_equal 'default', column_set.name
    vm = assigns(:vue_model)
    assert vm
    assert_equal column_set.name, vm.name
    assert_equal column_set.comment, vm.comment
    assert_equal column_set.header_columns.size, vm.header_columns.size
    [:header_columns, :footer_columns].each do |columns_attr|
      column_set.send(columns_attr).each do |column|
        column_vm = vm.send(columns_attr).detect { |col| col.physical_name == column.physical_name }
        assert column_vm
        [:logical_name, :data_type_id, :size, :scale, :nullable, :default_value, :comment].each do |attr|
          assert_equal column.send(attr), column_vm.send(attr)
        end
        assert_equal column.logical_name, column_vm.logical_name
      end
    end
  end

  def test_edit_by_viewer
    by_viewer
    get :edit, project_id: @project, database_id: @database, id: 1
    assert_response 403
  end

  def test_edit_by_not_member
    by_not_member
    get :edit, project_id: @project, database_id: @database, id: 1
    assert_response 403
  end

  def test_edit_with_invalid_project
    by_manager
    get :edit, project_id: 'invalid', database_id: @database, id: 1
    assert_response 404
  end

  def test_edit_with_invalid_database
    by_manager
    get :edit, project_id: @project, database_id: 'invalid', id: 1
    assert_response 404
  end

  def test_edit_with_invalid_id
    by_manager
    get :edit, project_id: @project, database_id: @database, id: -1
    assert_response 404
  end

  #TODO: update

  def test_destroy_by_manager
    by_manager
    assert_difference 'MxColumnSet.count', -1 do
      delete :destroy, project_id: @project, database_id: @database, id: 1
    end
    assert_response 302
    assert_redirected_to project_mx_database_column_sets_path(@project, @database)
    assert MxColumnSet.where(id: 1).empty?
  end

  def test_destroy_by_viewer
    by_viewer
    assert_no_difference 'MxColumnSet.count' do
      delete :destroy, project_id: @project, database_id: @database, id: 1
    end
    assert_response 403
  end

  def test_destroy_by_not_member
    by_not_member
    assert_no_difference 'MxColumnSet.count' do
      delete :destroy, project_id: @project, database_id: @database, id: 1
    end
    assert_response 403
  end

  def test_destroy_should_delete_mx_columns
    by_manager
    assert MxColumn.where(type: ['MxHeaderColumn', 'MxFooterColumn'], owner_id: 1).present?
    assert_difference 'MxColumn.count', -5 do
      delete :destroy, project_id: @project, database_id: @database, id: 1
    end
    assert MxColumn.where(type: ['MxHeaderColumn', 'MxFooterColumn'], owner_id: 1).empty?
  end

  def test_destroy_with_invalid_project
    by_manager
    assert_no_difference 'MxColumnSet.count' do
      delete :destroy, project_id: 'invalid', database_id: @database, id: 1
    end
    assert_response 404
  end

  def test_destroy_with_invalid_database
    by_manager
    assert_no_difference 'MxColumnSet.count' do
      delete :destroy, project_id: @project, database_id: 'invalid', id: 1
    end
    assert_response 404
  end

  def test_destroy_with_invalid_id
    by_manager
    assert_no_difference 'MxColumnSet.count' do
      delete :destroy, project_id: @project, database_id: @database, id: -1
    end
    assert_response 404
  end
end
