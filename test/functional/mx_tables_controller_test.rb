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

  #TODO: create

  # edit {{{

  def test_edit_by_manager
    get :edit, project_id: @project, database_id: @database, id: 1
    assert_response :success
    assert_template 'edit'
    table = assigns(:table)
    assert table
    assert_equal 1, table.id
    assert_equal 'customers', table.physical_name
    vm = assigns(:vue_model)
    assert vm
    assert_equal table.physical_name, vm.physical_name
    assert_equal table.logical_name, vm.logical_name
    assert_equal table.column_set_id, vm.column_set_id
    assert_equal table.comment, vm.comment
    assert_equal table.table_columns.size, vm.table_columns.size
    table.table_columns.each do |column|
      column_vm = vm.table_columns.detect { |col| col.physical_name == column.physical_name }
      assert column_vm
      [:logical_name, :data_type_id, :size, :scale, :nullable, :default_value, :comment].each do |attr|
        assert_equal column.send(attr), column_vm.send(attr)
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
    get :edit, project_id: 'invalid', database_id: @database, id: 1
    assert_response 404
  end

  def test_edit_with_invalid_database
    get :edit, project_id: @project, database_id: 'invalid', id: 1
    assert_response 404
  end

  def test_edit_with_invalid_id
    get :edit, project_id: @project, database_id: @database, id: -1
    assert_response 404
  end

  # }}}

  #TODO: update
end
