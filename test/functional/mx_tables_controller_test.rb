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

  # create {{{

  def test_create_by_manager_with_valid_params
    assert_create_success(valid_create_params)
    assert_saved_table(7, valid_create_params)
  end

  def test_create_by_viewer
    by_viewer
    assert_no_difference 'MxTable.count' do
      post :create, project_id: @project, database_id: @database, mx_table: valid_create_params
    end
    assert_response 403
  end

  def test_create_by_not_member
    by_not_member
    assert_no_difference 'MxTable.count' do
      post :create, project_id: @project, database_id: @database, mx_table: valid_create_params
    end
    assert_response 403
  end

  def test_create_with_invalid_project
    assert_no_difference 'MxTable.count' do
      post :create, project_id: 'invalid', database_id: @database, mx_table: valid_create_params
    end
    assert_response 404
  end

  def test_create_with_invalid_database
    assert_no_difference 'MxTable.count' do
      post :create, project_id: @project, database_id: 'invalid', mx_table: valid_create_params
    end
    assert_response 404
  end

  def test_create_without_physical_name
    params = valid_create_params.tap { |p| p.delete(:physical_name) }
    assert_create_failure(params)
    assert_have_error(:physical_name, "can't be blank")
  end

  def test_create_with_empty_physical_name
    params = valid_create_params.tap { |p| p[:physical_name] = '' }
    assert_create_failure(params)
    assert_have_error(:physical_name, "can't be blank")
  end

  def test_create_with_too_long_physical_name
    params = valid_create_params.tap { |p| p[:physical_name] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:physical_name, /is too long/)
  end

  def test_create_with_just_long_physical_name
    params = valid_create_params.tap { |p| p[:physical_name] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_already_taken_physical_name
    params = valid_create_params.tap { |p| p[:physical_name] = 'customers' }
    assert_create_failure(params)
    assert_have_error(:physical_name, 'has already been taken')
  end

  def test_create_with_already_taken_physical_name_in_other_database
    params = valid_create_params.tap { |p| p[:physical_name] = 'books' }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_without_logical_name
    params = valid_create_params.tap { |p| p.delete(:logical_name) }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_empty_logical_name
    params = valid_create_params.tap { |p| p[:logical_name] = '' }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_too_long_logical_name
    params = valid_create_params.tap { |p| p[:logical_name] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:logical_name, /is too long/)
  end

  def test_create_with_just_long_logical_name
    params = valid_create_params.tap { |p| p[:logical_name] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_without_comment
    params = valid_create_params.tap { |p| p.delete(:comment) }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_empty_comment
    params = valid_create_params.tap { |p| p[:comment] = '' }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_without_column_set_id
    params = valid_create_params.tap { |p| p.delete(:column_set_id) }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_empty_column_set_id
    params = valid_create_params.tap { |p| p[:column_set_id] = '' }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_invalid_column_set_id
    params = valid_create_params.tap { |p| p[:column_set_id] = 'a' }
    assert_create_failure(params)
    assert_have_error(:column_set_id, 'is not included in the list')
  end

  def test_create_without_columns
    params = valid_create_params.tap { |p| p.delete(:table_columns) }
    assert_difference 'MxTable.count', 1 do
      assert_no_difference 'MxColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(7)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert_saved_table(7, params)
    assert MxTableColumn.where(owner_id: 7).empty?
  end

  def test_create_without_column_physical_name
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'].delete(:physical_name) }
    assert_create_failure(params)
    assert_have_error(:column_physical_name, "can't be blank")
  end

  def test_create_with_too_long_column_physical_name
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:physical_name] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:column_physical_name, /is too long/)
  end

  def test_create_with_just_long_coumn_physical_name
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:physical_name] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_duplicated_column_physical_name
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:physical_name] = 'bar' }
    assert_create_failure(params)
    assert_have_error(:column_physical_name, 'is duplicated')
  end

  def test_create_with_column_physical_name_duplicated_with_column_of_column_set
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:physical_name] = 'id' }
    assert_create_failure(params)
    assert_have_error(:column_physical_name, 'is duplicated')
  end

  def test_create_without_column_logical_name
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'].delete(:logical_name) }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_too_long_column_logical_name
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:logical_name] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:column_logical_name, /is too long/)
  end

  def test_create_with_just_long_coumn_logical_name
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:logical_name] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_without_column_data_type_id
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'].delete(:data_type_id) }
    assert_create_failure(params)
    assert_have_error(:column_data_type_id, "can't be blank")
  end

  def test_create_with_column_data_type_id_that_not_belong_to_table_belonging_dbms_product
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:data_type_id] = '57' }
    assert_create_failure(params)
    assert_have_error(:column_data_type_id, 'is not included in the list')
  end

  def test_create_without_column_size
    params = valid_create_params.tap { |p| p[:table_columns]['v-column3'].delete(:size) }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_empty_column_size
    params = valid_create_params.tap { |p| p[:table_columns]['v-column3'][:size] = '' }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_not_numeric_column_size
    params = valid_create_params.tap { |p| p[:table_columns]['v-column3'][:size] = 'a' }
    assert_create_failure(params)
    assert_have_error(:column_size, 'is not a number')
  end

  def test_create_with_negative_numeric_column_size
    params = valid_create_params.tap { |p| p[:table_columns]['v-column3'][:size] = '-1' }
    assert_create_failure(params)
    assert_have_error(:column_size, 'must be greater than 0')
  end

  def test_create_with_column_size_when_data_type_is_not_sizable
    params = valid_create_params.tap { |p| p[:table_columns]['v-column2'][:size] = '10' }
    assert_create_success(params)
    assert_saved_table(7, params, :column_size)
    table = MxTable.find(7)
    assert_nil table.table_columns.where(physical_name: 'bar').first.size
  end

  def test_create_without_column_scale
    params = valid_create_params.tap { |p| p[:table_columns]['v-column3'].delete(:scale) }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_empty_column_scale
    params = valid_create_params.tap { |p| p[:table_columns]['v-column3'][:scale] = '' }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_not_numeric_column_scale
    params = valid_create_params.tap { |p| p[:table_columns]['v-column3'][:scale] = 'a' }
    assert_create_failure(params)
    assert_have_error(:column_scale, 'is not a number')
  end

  def test_create_with_negative_numeric_column_scale
    params = valid_create_params.tap { |p| p[:table_columns]['v-column3'][:scale] = '-1' }
    assert_create_failure(params)
    assert_have_error(:column_scale, 'must be greater than 0')
  end

  def test_create_with_column_scale_when_data_type_is_not_scalable
    params = valid_create_params.tap { |p| p[:table_columns]['v-column2'][:scale] = '10' }
    assert_create_success(params)
    assert_saved_table(7, params, :column_scale)
    table = MxTable.find(7)
    assert_nil table.table_columns.where(physical_name: 'bar').first.scale
  end

  def test_create_without_column_nullable
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'].delete(:nullable) }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_empty_column_nullable
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:nullable] = '' }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_column_nullable_not_true
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:nullable] = 'foo' }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_without_column_default_value
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'].delete(:default_value) }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_empty_column_default_value
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:default_value] = '' }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_with_too_long_column_default_value
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:default_value] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:column_default_value, /is too long/)
  end

  def test_create_with_just_long_coumn_default_value
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'][:default_value] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  def test_create_without_column_comment
    params = valid_create_params.tap { |p| p[:table_columns]['v-column1'].delete(:comment) }
    assert_create_success(params)
    assert_saved_table(7, params)
  end

  # }}}

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

  private

  def valid_create_params
    {
      physical_name: 'test',
      logical_name: 'Test table',
      comment: "foo\nbar\nbaz",
      column_set_id: '1',
      table_columns: {
        'v-column1' => {
          id: 'v-column1',
          physical_name: 'foo',
          logical_name: 'FOO',
          data_type_id: '12',
          size: '150',
          nullable: 'true',
          comment: 'foo column',
          position: '0'
        },
        'v-column2' => {
          id: 'v-column2',
          physical_name: 'bar',
          logical_name: 'BAR',
          data_type_id: '21',
          default_value: 'false',
          comment: 'bar column',
          position: '1'
        },
        'v-column3' => {
          id: 'v-column3',
          physical_name: 'baz',
          logical_name: 'BAZ',
          data_type_id: '5',
          size: '10',
          size: '2',
          nulable: 'true',
          default_value: '0.0',
          comment: 'baz column',
          position: '2'
        }
      }
    }
  end

  def assert_saved_table(id, params, ignore=nil)
    table = MxTable.find(id)
    assert_equal params[:physical_name], table.physical_name
    assert_equal params[:logical_name], table.logical_name
    assert_equal params[:comment].presence, table.comment
    assert_column_set(table, params)
    assert_columns(table, params, ignore)
  end

  def assert_column_set(table, params)
    if params[:column_set_id].present?
      assert_equal params[:column_set_id], table.column_set_id.to_s
      column_set = MxColumnSet.find(params[:column_set_id])
      assert_equal column_set.header_columns.to_a, table.columns[0...column_set.header_columns.size]
      footer_start_index = column_set.header_columns.size + table.table_columns.size
      assert_equal column_set.footer_columns.to_a, table.columns[footer_start_index..-1]
    else
      assert_nil table.column_set
      assert_equal table.table_columns.to_a, table.columns
    end
  end

  def assert_columns(table, params, ignore)
    if params[:table_columns]
      assert_equal params[:table_columns].size, table.table_columns.size
      params[:table_columns].each do |_, column_params|
        column = table.table_columns.where(physical_name: column_params[:physical_name]).first
        assert_column(column, column_params, ignore)
      end
    else
      assert_equal 0, table.table_columns.size
    end
  end

  def assert_column(column, column_params, ignore)
    assert column
    assert_equal column_params[:logical_name], column.logical_name
    assert_equal column_params[:data_type_id], column.data_type_id.to_s
    unless ignore == :column_size
      if column_params[:size].present?
        assert_equal column_params[:size], column.size.to_s
      else
        assert_nil column.size
      end
    end
    unless ignore == :column_scale
      if column_params[:scale].present?
        assert_equal column_params[:scale], column.scale.to_s
      else
        assert_nil column.scale
      end
    end
    assert_equal column_params[:nullable].present?, column.nullable
    assert_equal column_params[:default_value], column.default_value
    assert_equal column_params[:comment].presence, column.comment
  end

  def assert_have_error(attribute, error)
    if error.is_a?(Regexp)
      assert_match error, assigns(:vue_model).errors[attribute].first
    else
      assert_equal error, assigns(:vue_model).errors[attribute].first
    end
  end

  def assert_create_success(params, column_count=3)
    assert_difference 'MxTable.count', 1 do
      assert_difference 'MxColumn.count', column_count do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(7)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
  end

  def assert_create_failure(params)
    assert_no_difference 'MxTable.count' do
      assert_no_difference 'MxColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response :success
    assert_template 'new'
  end

end
