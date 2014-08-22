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

  # index {{{

  def test_index_by_manager
    get :index, project_id: @project, database_id: @database
    assert_response :success
    assert_template 'index'
    database = assigns(:database)
    assert_equal 5, database.tables.size
    database.tables.each do |table|
      assert_tag tag: 'a', attributes: { href: project_mx_database_table_path(@project, @database, table) }
      assert_tag tag: 'a', attributes: { href: project_mx_database_table_path(@project, @database, table), 'data-method' => 'delete' }
    end
    assert_tag tag: 'a', attributes: { href: new_project_mx_database_table_path(@project, @database) }
  end

  def test_index_by_viewer
    by_viewer
    get :index, project_id: @project, database_id: @database
    assert_response :success
    assert_template 'index'
    database = assigns(:database)
    assert_equal 5, database.tables.size
    database.tables.each do |table|
      assert_tag tag: 'a', attributes: { href: project_mx_database_table_path(@project, @database, table) }
      assert_no_tag tag: 'a', attributes: { href: project_mx_database_table_path(@project, @database, table), 'data-method' => 'delete' }
    end
    assert_no_tag tag: 'a', attributes: { href: new_project_mx_database_table_path(@project, @database) }
  end

  def test_index_by_not_member
    by_not_member
    get :index, project_id: @project, database_id: @database
    assert_response 403
  end

  def test_index_with_invalid_project
    get :index, project_id: 'invalid', database_id: @database
    assert_response 404
  end

  def test_index_with_invalid_database
    get :index, project_id: @project, database_id: 'invalid'
    assert_response 404
  end

  # }}}

  # show {{{

  def test_show_by_manager
    get :show, project_id: @project, database_id: @database, id: 'customers'
    assert_response :success
    assert_template 'show'
    table = assigns(:table)
    assert table
    assert_equal 'customers', table.physical_name
    assert_equal 12, table.columns.size
    assert_equal 7, table.table_columns.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_tables_path(@project, @database) }
    assert_tag tag: 'a', attributes: { href: edit_project_mx_database_table_path(@project, @database, table) }
    assert_tag tag: 'a', attributes: { href: project_mx_database_table_path(@project, @database, table) }
  end

  def test_show_by_viewer
    by_viewer
    get :show, project_id: @project, database_id: @database, id: 'customers'
    assert_response :success
    assert_template 'show'
    table = assigns(:table)
    assert table
    assert_equal 'customers', table.physical_name
    assert_equal 12, table.columns.size
    assert_equal 7, table.table_columns.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_tables_path(@project, @database) }
    assert_no_tag tag: 'a', attributes: { href: edit_project_mx_database_table_path(@project, @database, table) }
    assert_no_tag tag: 'a', attributes: { href: project_mx_database_table_path(@project, @database, table) }
  end

  def test_show_by_not_member
    by_not_member
    get :show, project_id: @project, database_id: @database, id: 'customers'
    assert_response 403
  end

  def test_show_with_id
    get :show, project_id: @project, database_id: @database, id: 1
    assert_response :success
    assert_template 'show'
    table = assigns(:table)
    assert table
    assert_equal 'customers', table.physical_name
    assert_equal 12, table.columns.size
    assert_equal 7, table.table_columns.size
    assert_tag tag: 'a', attributes: { href: project_mx_database_tables_path(@project, @database) }
    assert_tag tag: 'a', attributes: { href: edit_project_mx_database_table_path(@project, @database, table) }
    assert_tag tag: 'a', attributes: { href: project_mx_database_table_path(@project, @database, table) }
  end

  def test_show_with_invalid_project
    get :show, project_id: 'invalid', database_id: @database, id: 'customers'
    assert_response 404
  end

  def test_show_with_invalid_database
    get :show, project_id: @project, database_id: 'invalid', id: 'customers'
    assert_response 404
  end

  def test_show_with_invalid_physical_name
    get :show, project_id: @project, database_id: @database, id: 'invalid'
    assert_response 404
  end

  def test_show_with_invalid_id
    get :show, project_id: @project, database_id: @database, id: -1
    assert_response 404
  end

  # }}}

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

  # destroy {{{

  def test_destroy_by_manager
    assert_difference 'MxTable.count', -1 do
      assert_difference 'MxColumn.count', -7 do
        delete :destroy, project_id: @project, database_id: @database, id: 1
      end
    end
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, @database)
    assert MxTable.where(id: 1).empty?
    assert MxColumn.where(type: 'MxTableColumn', owner_id: 1).empty?
  end

  def test_destroy_by_viewer
    by_viewer
    assert_no_difference 'MxTable.count' do
      delete :destroy, project_id: @project, database_id: @database, id: 1
    end
    assert_response 403
  end

  def test_destroy_by_not_member
    by_not_member
    assert_no_difference 'MxTable.count' do
      delete :destroy, project_id: @project, database_id: @database, id: 1
    end
    assert_response 403
  end

  def test_destroy_with_invalid_project
    assert_no_difference 'MxTable.count' do
      delete :destroy, project_id: 'invalid', database_id: @database, id: 1
    end
    assert_response 404
  end

  def test_destroy_with_invalid_database
    assert_no_difference 'MxTable.count' do
      delete :destroy, project_id: @project, database_id: 'invalid', id: 1
    end
    assert_response 404
  end

  def test_destroy_with_invalid_id
    assert_no_difference 'MxTable.count' do
      delete :destroy, project_id: @project, database_id: @database, id: -1
    end
    assert_response 404
  end

  # }}}
end
