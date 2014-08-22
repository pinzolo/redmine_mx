require File.expand_path('../../test_helper', __FILE__)

class MxColumnSetsControllerTest < ActionController::TestCase
  fixtures :users, :projects, :members, :roles, :member_roles,
    :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_column_sets, :mx_columns

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
    get :show, project_id: 'invalid', database_id: @database, id: 1
    assert_response 404
  end

  def test_show_with_invalid_database
    get :show, project_id: @project, database_id: 'invalid', id: 1
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
    assert_saved_column_set(4, valid_create_params)
  end

  def test_create_by_viewer
    by_viewer
    assert_no_difference 'MxColumnSet.count' do
      post :create, project_id: @project, database_id: @database, mx_column_set: valid_create_params
    end
    assert_response 403
  end

  def test_create_by_not_member
    by_not_member
    assert_no_difference 'MxColumnSet.count' do
      post :create, project_id: @project, database_id: @database, mx_column_set: valid_create_params
    end
    assert_response 403
  end

  def test_create_with_invalid_project
    assert_no_difference 'MxColumnSet.count' do
      post :create, project_id: 'invalid', database_id: @database, mx_column_set: valid_create_params
    end
    assert_response 404
  end

  def test_create_with_invalid_database
    assert_no_difference 'MxColumnSet.count' do
      post :create, project_id: @project, database_id: 'invalid', mx_column_set: valid_create_params
    end
    assert_response 404
  end

  def test_create_without_name
    params = valid_create_params.tap { |p| p.delete(:name) }
    assert_create_failure(params)
    assert_have_error(:name, "can't be blank")
  end

  def test_create_with_empty_name
    params = valid_create_params.tap { |p| p[:name] = '' }
    assert_create_failure(params)
    assert_have_error(:name, "can't be blank")
  end

  def test_create_with_too_long_name
    params = valid_create_params.tap { |p| p[:name] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:name, /is too long/)
  end

  def test_create_with_just_long_name
    params = valid_create_params.tap { |p| p[:name] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_already_taken_name
    params = valid_create_params.tap { |p| p[:name] = 'default' }
    assert_create_failure(params)
    assert_have_error(:name, 'has already been taken')
  end

  def test_create_with_already_taken_name_in_other_database
    params = valid_create_params.tap { |p| p[:name] = 'basic' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_without_comment
    params = valid_create_params.tap { |p| p.delete(:comment) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_empty_comment
    params = valid_create_params.tap { |p| p[:comment] = '' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_without_header_columns
    params = valid_create_params.tap { |p| p.delete(:header_columns) }
    assert_create_success(params, 3)
    assert_saved_column_set(4, params)
    assert MxHeaderColumn.where(owner_id: 4).empty?
  end

  def test_create_without_footer_columns
    params = valid_create_params.tap { |p| p.delete(:footer_columns) }
    assert_create_success(params, 3)
    assert_saved_column_set(4, params)
    assert MxFooterColumn.where(owner_id: 4).empty?
  end

  def test_create_without_header_columns_and_footer_columns
    params = valid_create_params.tap do |p|
      p.delete(:header_columns)
      p.delete(:footer_columns)
    end
    assert_difference 'MxColumnSet.count', 1 do
      assert_no_difference 'MxColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_column_set: params
      end
    end
    assert_response 302
    assert_redirected_to project_mx_database_column_set_path(@project, @database, 4)
    assert_saved_column_set(4, params)
    assert MxHeaderColumn.where(owner_id: 4).empty?
    assert MxFooterColumn.where(owner_id: 4).empty?
  end

  def test_create_without_header_column_physical_name
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'].delete(:physical_name) }
    assert_create_failure(params)
    assert_have_error(:header_column_physical_name, "can't be blank")
  end

  def test_create_with_too_long_header_column_physical_name
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:physical_name] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:header_column_physical_name, /is too long/)
  end

  def test_create_with_just_long_header_coumn_physical_name
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:physical_name] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_duplicated_header_column_physical_name
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:physical_name] = 'h_bar' }
    assert_create_failure(params)
    assert_have_error(:header_column_physical_name, 'is duplicated')
  end

  def test_create_without_header_column_logical_name
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'].delete(:logical_name) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_too_long_header_column_logical_name
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:logical_name] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:header_column_logical_name, /is too long/)
  end

  def test_create_with_just_long_header_coumn_logical_name
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:logical_name] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_without_header_column_data_type_id
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'].delete(:data_type_id) }
    assert_create_failure(params)
    assert_have_error(:header_column_data_type_id, "can't be blank")
  end

  def test_create_with_header_column_data_type_id_that_not_belong_to_column_set_belonging_dbms_product
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:data_type_id] = '57' }
    assert_create_failure(params)
    assert_have_error(:header_column_data_type_id, 'is not included in the list')
  end

  def test_create_without_header_column_size
    params = valid_create_params.tap { |p| p[:header_columns]['v-hc'].delete(:size) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_empty_header_column_size
    params = valid_create_params.tap { |p| p[:header_columns]['v-hc'][:size] = '' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_not_numeric_header_column_size
    params = valid_create_params.tap { |p| p[:header_columns]['v-hc'][:size] = 'a' }
    assert_create_failure(params)
    assert_have_error(:header_column_size, 'is not a number')
  end

  def test_create_with_negative_numeric_header_column_size
    params = valid_create_params.tap { |p| p[:header_columns]['v-hc'][:size] = '-1' }
    assert_create_failure(params)
    assert_have_error(:header_column_size, 'must be greater than 0')
  end

  def test_create_with_header_column_size_when_data_type_is_not_sizable
    params = valid_create_params.tap { |p| p[:header_columns]['v-hb'][:size] = '10' }
    assert_create_success(params)
    assert_saved_column_set(4, params, :header_column_size)
    column_set = MxColumnSet.find(4)
    assert_nil column_set.header_columns.where(physical_name: 'h_bar').first.size
  end

  def test_create_without_header_column_scale
    params = valid_create_params.tap { |p| p[:header_columns]['v-hc'].delete(:scale) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_empty_header_column_scale
    params = valid_create_params.tap { |p| p[:header_columns]['v-hc'][:scale] = '' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_not_numeric_header_column_scale
    params = valid_create_params.tap { |p| p[:header_columns]['v-hc'][:scale] = 'a' }
    assert_create_failure(params)
    assert_have_error(:header_column_scale, 'is not a number')
  end

  def test_create_with_negative_numeric_header_column_scale
    params = valid_create_params.tap { |p| p[:header_columns]['v-hc'][:scale] = '-1' }
    assert_create_failure(params)
    assert_have_error(:header_column_scale, 'must be greater than 0')
  end

  def test_create_with_header_column_scale_when_data_type_is_not_scalable
    params = valid_create_params.tap { |p| p[:header_columns]['v-hb'][:scale] = '10' }
    assert_create_success(params)
    assert_saved_column_set(4, params, :header_column_scale)
    column_set = MxColumnSet.find(4)
    assert_nil column_set.header_columns.where(physical_name: 'h_bar').first.scale
  end

  def test_create_without_header_column_nullable
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'].delete(:nullable) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_empty_header_column_nullable
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:nullable] = '' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_header_column_nullable_not_true
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:nullable] = 'foo' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_without_header_column_default_value
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'].delete(:default_value) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_empty_header_column_default_value
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:default_value] = '' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_too_long_header_column_default_value
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:default_value] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:header_column_default_value, /is too long/)
  end

  def test_create_with_just_long_header_coumn_default_value
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:default_value] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_without_header_column_comment
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'].delete(:comment) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_without_footer_column_physical_name
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'].delete(:physical_name) }
    assert_create_failure(params)
    assert_have_error(:footer_column_physical_name, "can't be blank")
  end

  def test_create_with_too_long_footer_column_physical_name
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:physical_name] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:footer_column_physical_name, /is too long/)
  end

  def test_create_with_just_long_footer_coumn_physical_name
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:physical_name] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_duplicated_footer_column_physical_name
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:physical_name] = 'f_bar' }
    assert_create_failure(params)
    assert_have_error(:footer_column_physical_name, 'is duplicated')
  end

  def test_create_without_footer_column_logical_name
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'].delete(:logical_name) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_too_long_footer_column_logical_name
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:logical_name] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:footer_column_logical_name, /is too long/)
  end

  def test_create_with_just_long_footer_coumn_logical_name
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:logical_name] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_without_footer_column_data_type_id
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'].delete(:data_type_id) }
    assert_create_failure(params)
    assert_have_error(:footer_column_data_type_id, "can't be blank")
  end

  def test_create_with_footer_column_data_type_id_that_not_belong_to_column_set_belonging_dbms_product
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:data_type_id] = '57' }
    assert_create_failure(params)
    assert_have_error(:footer_column_data_type_id, 'is not included in the list')
  end

  def test_create_without_footer_column_size
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fc'].delete(:size) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_empty_footer_column_size
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fc'][:size] = '' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_not_numeric_footer_column_size
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fc'][:size] = 'a' }
    assert_create_failure(params)
    assert_have_error(:footer_column_size, 'is not a number')
  end

  def test_create_with_negative_numeric_footer_column_size
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fc'][:size] = '-1' }
    assert_create_failure(params)
    assert_have_error(:footer_column_size, 'must be greater than 0')
  end

  def test_create_with_footer_column_size_when_data_type_is_not_sizable
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fb'][:size] = '10' }
    assert_create_success(params)
    assert_saved_column_set(4, params, :footer_column_size)
    column_set = MxColumnSet.find(4)
    assert_nil column_set.footer_columns.where(physical_name: 'f_bar').first.size
  end

  def test_create_without_footer_column_scale
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fc'].delete(:scale) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_empty_footer_column_scale
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fc'][:scale] = '' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_not_numeric_footer_column_scale
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fc'][:scale] = 'a' }
    assert_create_failure(params)
    assert_have_error(:footer_column_scale, 'is not a number')
  end

  def test_create_with_negative_numeric_footer_column_scale
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fc'][:scale] = '-1' }
    assert_create_failure(params)
    assert_have_error(:footer_column_scale, 'must be greater than 0')
  end

  def test_create_with_footer_column_scale_when_data_type_is_not_scalable
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fb'][:scale] = '10' }
    assert_create_success(params)
    assert_saved_column_set(4, params, :footer_column_scale)
    column_set = MxColumnSet.find(4)
    assert_nil column_set.footer_columns.where(physical_name: 'f_bar').first.scale
  end

  def test_create_without_footer_column_nullable
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'].delete(:nullable) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_empty_footer_column_nullable
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:nullable] = '' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_footer_column_nullable_not_true
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:nullable] = 'foo' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_without_footer_column_default_value
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'].delete(:default_value) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_empty_footer_column_default_value
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:default_value] = '' }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_too_long_footer_column_default_value
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:default_value] = 'a' * 201 }
    assert_create_failure(params)
    assert_have_error(:footer_column_default_value, /is too long/)
  end

  def test_create_with_just_long_footer_coumn_default_value
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'][:default_value] = 'a' * 200 }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_without_footer_column_comment
    params = valid_create_params.tap { |p| p[:footer_columns]['v-fa'].delete(:comment) }
    assert_create_success(params)
    assert_saved_column_set(4, params)
  end

  def test_create_with_duplicated_type_names_on_header_and_footer
    params = valid_create_params.tap { |p| p[:header_columns]['v-ha'][:physical_name] = 'f_foo' }
    assert_create_failure(params)
    assert_have_error(:header_column_physical_name, 'is duplicated')
    assert_have_error(:footer_column_physical_name, 'is duplicated')
  end

  # }}}

  # edit {{{

  def test_edit_by_manager
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
    assert_equal column_set.footer_columns.size, vm.footer_columns.size
    [:header_columns, :footer_columns].each do |columns_attr|
      column_set.send(columns_attr).each do |column|
        column_vm = vm.send(columns_attr).detect { |col| col.physical_name == column.physical_name }
        assert column_vm
        [:logical_name, :data_type_id, :size, :scale, :nullable, :default_value, :comment].each do |attr|
          assert_equal column.send(attr), column_vm.send(attr)
        end
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

  # update {{{

  def test_update_by_manager_with_valid_params
    assert_update_success(valid_update_params, 1)
    assert_saved_column_set(1, valid_update_params)
  end

  def test_update_by_viewer
    by_viewer
    assert_no_difference 'MxColumnSet.count' do
      put :update, project_id: @project, database_id: @database, id: 1, mx_column_set: valid_update_params
    end
    assert_response 403
  end

  def test_update_by_not_member
    by_not_member
    assert_no_difference 'MxColumnSet.count' do
      put :update, project_id: @project, database_id: @database, id: 1, mx_column_set: valid_update_params
    end
    assert_response 403
  end

  def test_update_with_invalid_project
    assert_no_difference 'MxColumnSet.count' do
      put :update, project_id: 'invalid', database_id: @database, id: 1, mx_column_set: valid_update_params
    end
    assert_response 404
  end

  def test_update_with_invalid_database
    assert_no_difference 'MxColumnSet.count' do
      put :update, project_id: @project, database_id: 'invalid', id: 1, mx_column_set: valid_update_params
    end
    assert_response 404
  end

  def test_update_without_name
    params = valid_update_params.tap { |p| p.delete(:name) }
    assert_update_failure(params)
    assert_have_error(:name, "can't be blank")
  end

  def test_update_with_empty_name
    params = valid_update_params.tap { |p| p[:name] = '' }
    assert_update_failure(params)
    assert_have_error(:name, "can't be blank")
  end

  def test_update_with_too_long_name
    params = valid_update_params.tap { |p| p[:name] = 'a' * 201 }
    assert_update_failure(params)
    assert_have_error(:name, /is too long/)
  end

  def test_update_with_just_long_name
    params = valid_update_params.tap { |p| p[:name] = 'a' * 200 }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_same_name
    params = valid_update_params.tap { |p| p[:name] = 'default' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_already_taken_name
    params = valid_update_params.tap { |p| p[:name] = 'simple' }
    assert_update_failure(params)
    assert_have_error(:name, 'has already been taken')
  end

  def test_update_with_already_taken_name_in_other_database
    params = valid_update_params.tap { |p| p[:name] = 'basic' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_without_comment
    params = valid_update_params.tap { |p| p.delete(:comment) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_empty_comment
    params = valid_update_params.tap { |p| p[:comment] = '' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_without_header_columns
    params = valid_update_params.tap { |p| p.delete(:header_columns) }
    assert_update_success(params, -2)
    assert_saved_column_set(1, params)
    assert MxHeaderColumn.where(owner_id: 1).empty?
  end

  def test_update_without_footer_columns
    params = valid_update_params.tap { |p| p.delete(:footer_columns) }
    assert_update_success(params, -2)
    assert_saved_column_set(1, params)
    assert MxFooterColumn.where(owner_id: 1).empty?
  end

  def test_update_without_header_columns_and_footer_columns
    params = valid_update_params.tap do |p|
      p.delete(:header_columns)
      p.delete(:footer_columns)
    end
    assert_update_success(params, -5)
    assert_saved_column_set(1, params)
    assert MxHeaderColumn.where(owner_id: 1).empty?
    assert MxFooterColumn.where(owner_id: 1).empty?
  end

  def test_update_without_header_column_physical_name
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'].delete(:physical_name) }
    assert_update_failure(params)
    assert_have_error(:header_column_physical_name, "can't be blank")
  end

  def test_update_with_too_long_header_column_physical_name
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:physical_name] = 'a' * 201 }
    assert_update_failure(params)
    assert_have_error(:header_column_physical_name, /is too long/)
  end

  def test_update_with_just_long_header_coumn_physical_name
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:physical_name] = 'a' * 200 }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_duplicated_header_column_physical_name
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:physical_name] = 'h_bar' }
    assert_update_failure(params)
    assert_have_error(:header_column_physical_name, 'is duplicated')
  end

  def test_update_without_header_column_logical_name
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'].delete(:logical_name) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_too_long_header_column_logical_name
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:logical_name] = 'a' * 201 }
    assert_update_failure(params)
    assert_have_error(:header_column_logical_name, /is too long/)
  end

  def test_update_with_just_long_header_coumn_logical_name
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:logical_name] = 'a' * 200 }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_without_header_column_data_type_id
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'].delete(:data_type_id) }
    assert_update_failure(params)
    assert_have_error(:header_column_data_type_id, "can't be blank")
  end

  def test_update_with_header_column_data_type_id_that_not_belong_to_column_set_belonging_dbms_product
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:data_type_id] = '57' }
    assert_update_failure(params)
    assert_have_error(:header_column_data_type_id, 'is not included in the list')
  end

  def test_update_without_header_column_size
    params = valid_update_params.tap { |p| p[:header_columns]['v-hc'].delete(:size) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_empty_header_column_size
    params = valid_update_params.tap { |p| p[:header_columns]['v-hc'][:size] = '' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_not_numeric_header_column_size
    params = valid_update_params.tap { |p| p[:header_columns]['v-hc'][:size] = 'a' }
    assert_update_failure(params)
    assert_have_error(:header_column_size, 'is not a number')
  end

  def test_update_with_negative_numeric_header_column_size
    params = valid_update_params.tap { |p| p[:header_columns]['v-hc'][:size] = '-1' }
    assert_update_failure(params)
    assert_have_error(:header_column_size, 'must be greater than 0')
  end

  def test_update_with_header_column_size_when_data_type_is_not_sizable
    params = valid_update_params.tap { |p| p[:header_columns]['v-hb'][:size] = '10' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params, :header_column_size)
    column_set = MxColumnSet.find(1)
    assert_nil column_set.header_columns.where(physical_name: 'h_bar').first.size
  end

  def test_update_without_header_column_scale
    params = valid_update_params.tap { |p| p[:header_columns]['v-hc'].delete(:scale) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_empty_header_column_scale
    params = valid_update_params.tap { |p| p[:header_columns]['v-hc'][:scale] = '' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_not_numeric_header_column_scale
    params = valid_update_params.tap { |p| p[:header_columns]['v-hc'][:scale] = 'a' }
    assert_update_failure(params)
    assert_have_error(:header_column_scale, 'is not a number')
  end

  def test_update_with_negative_numeric_header_column_scale
    params = valid_update_params.tap { |p| p[:header_columns]['v-hc'][:scale] = '-1' }
    assert_update_failure(params)
    assert_have_error(:header_column_scale, 'must be greater than 0')
  end

  def test_update_with_header_column_scale_when_data_type_is_not_scalable
    params = valid_update_params.tap { |p| p[:header_columns]['v-hb'][:scale] = '10' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params, :header_column_scale)
    column_set = MxColumnSet.find(1)
    assert_nil column_set.header_columns.where(physical_name: 'h_bar').first.scale
  end

  def test_update_without_header_column_nullable
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'].delete(:nullable) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_empty_header_column_nullable
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:nullable] = '' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_header_column_nullable_not_true
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:nullable] = 'foo' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_without_header_column_default_value
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'].delete(:default_value) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_empty_header_column_default_value
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:default_value] = '' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_too_long_header_column_default_value
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:default_value] = 'a' * 201 }
    assert_update_failure(params)
    assert_have_error(:header_column_default_value, /is too long/)
  end

  def test_update_with_just_long_header_coumn_default_value
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:default_value] = 'a' * 200 }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_without_header_column_comment
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'].delete(:comment) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_without_footer_column_physical_name
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'].delete(:physical_name) }
    assert_update_failure(params)
    assert_have_error(:footer_column_physical_name, "can't be blank")
  end

  def test_update_with_too_long_footer_column_physical_name
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:physical_name] = 'a' * 201 }
    assert_update_failure(params)
    assert_have_error(:footer_column_physical_name, /is too long/)
  end

  def test_update_with_just_long_footer_coumn_physical_name
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:physical_name] = 'a' * 200 }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_duplicated_footer_column_physical_name
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:physical_name] = 'f_bar' }
    assert_update_failure(params)
    assert_have_error(:footer_column_physical_name, 'is duplicated')
  end

  def test_update_without_footer_column_logical_name
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'].delete(:logical_name) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_too_long_footer_column_logical_name
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:logical_name] = 'a' * 201 }
    assert_update_failure(params)
    assert_have_error(:footer_column_logical_name, /is too long/)
  end

  def test_update_with_just_long_footer_coumn_logical_name
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:logical_name] = 'a' * 200 }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_without_footer_column_data_type_id
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'].delete(:data_type_id) }
    assert_update_failure(params)
    assert_have_error(:footer_column_data_type_id, "can't be blank")
  end

  def test_update_with_footer_column_data_type_id_that_not_belong_to_column_set_belonging_dbms_product
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:data_type_id] = '57' }
    assert_update_failure(params)
    assert_have_error(:footer_column_data_type_id, 'is not included in the list')
  end

  def test_update_without_footer_column_size
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fc'].delete(:size) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_empty_footer_column_size
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fc'][:size] = '' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_not_numeric_footer_column_size
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fc'][:size] = 'a' }
    assert_update_failure(params)
    assert_have_error(:footer_column_size, 'is not a number')
  end

  def test_update_with_negative_numeric_footer_column_size
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fc'][:size] = '-1' }
    assert_update_failure(params)
    assert_have_error(:footer_column_size, 'must be greater than 0')
  end

  def test_update_with_footer_column_size_when_data_type_is_not_sizable
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fb'][:size] = '10' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params, :footer_column_size)
    column_set = MxColumnSet.find(1)
    assert_nil column_set.footer_columns.where(physical_name: 'f_bar').first.size
  end

  def test_update_without_footer_column_scale
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fc'].delete(:scale) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_empty_footer_column_scale
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fc'][:scale] = '' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_not_numeric_footer_column_scale
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fc'][:scale] = 'a' }
    assert_update_failure(params)
    assert_have_error(:footer_column_scale, 'is not a number')
  end

  def test_update_with_negative_numeric_footer_column_scale
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fc'][:scale] = '-1' }
    assert_update_failure(params)
    assert_have_error(:footer_column_scale, 'must be greater than 0')
  end

  def test_update_with_footer_column_scale_when_data_type_is_not_scalable
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fb'][:scale] = '10' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params, :footer_column_scale)
    column_set = MxColumnSet.find(1)
    assert_nil column_set.footer_columns.where(physical_name: 'f_bar').first.scale
  end

  def test_update_without_footer_column_nullable
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'].delete(:nullable) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_empty_footer_column_nullable
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:nullable] = '' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_footer_column_nullable_not_true
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:nullable] = 'foo' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_without_footer_column_default_value
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'].delete(:default_value) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_empty_footer_column_default_value
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:default_value] = '' }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_too_long_footer_column_default_value
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:default_value] = 'a' * 201 }
    assert_update_failure(params)
    assert_have_error(:footer_column_default_value, /is too long/)
  end

  def test_update_with_just_long_footer_coumn_default_value
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'][:default_value] = 'a' * 200 }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_without_footer_column_comment
    params = valid_update_params.tap { |p| p[:footer_columns]['v-fa'].delete(:comment) }
    assert_update_success(params, 1)
    assert_saved_column_set(1, params)
  end

  def test_update_with_duplicated_type_names_on_header_and_footer
    params = valid_update_params.tap { |p| p[:header_columns]['v-ha'][:physical_name] = 'f_foo' }
    assert_update_failure(params)
    assert_have_error(:header_column_physical_name, 'is duplicated')
    assert_have_error(:footer_column_physical_name, 'is duplicated')
  end

  def test_update_with_invalid_lock_version
    params = valid_update_params.tap { |p| p[:lock_version] = '1' }
    assert_update_failure(params)
    assert_conflict_flash
  end

  # }}}

  # destroy {{{

  def test_destroy_by_manager
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
    assert MxColumn.where(type: ['MxHeaderColumn', 'MxFooterColumn'], owner_id: 1).present?
    assert_difference 'MxColumn.count', -5 do
      delete :destroy, project_id: @project, database_id: @database, id: 1
    end
    assert MxColumn.where(type: ['MxHeaderColumn', 'MxFooterColumn'], owner_id: 1).empty?
  end

  def test_destroy_with_invalid_project
    assert_no_difference 'MxColumnSet.count' do
      delete :destroy, project_id: 'invalid', database_id: @database, id: 1
    end
    assert_response 404
  end

  def test_destroy_with_invalid_database
    assert_no_difference 'MxColumnSet.count' do
      delete :destroy, project_id: @project, database_id: 'invalid', id: 1
    end
    assert_response 404
  end

  def test_destroy_with_invalid_id
    assert_no_difference 'MxColumnSet.count' do
      delete :destroy, project_id: @project, database_id: @database, id: -1
    end
    assert_response 404
  end

  # }}}

  private

  def valid_create_params
    {
      name: 'test',
      comment: "foo\nbar\nbaz",
      header_columns: {
        'v-ha' => {
          id: 'v-ha',
          physical_name: 'h_foo',
          logical_name: 'H-FOO',
          data_type_id: '12',
          size: '150',
          nullable: 'true',
          comment: 'foo header column',
          position: '0'
        },
        'v-hb' => {
          id: 'v-hb',
          physical_name: 'h_bar',
          logical_name: 'H-BAR',
          data_type_id: '21',
          default_value: 'false',
          comment: 'bar header column',
          position: '1'
        },
        'v-hc' => {
          id: 'v-hc',
          physical_name: 'h_baz',
          logical_name: 'H-BAZ',
          data_type_id: '5',
          size: '10',
          size: '2',
          nulable: 'true',
          default_value: '0.0',
          comment: 'baz header column',
          position: '2'
        }
      },
      footer_columns: {
        'v-fa' => {
          id: 'v-fa',
          physical_name: 'f_foo',
          logical_name: 'F-FOO',
          data_type_id: '12',
          size: '150',
          nullable: 'true',
          comment: 'foo footer column',
          position: '0'
        },
        'v-fb' => {
          id: 'v-fb',
          physical_name: 'f_bar',
          logical_name: 'F-BAR',
          data_type_id: '21',
          default_value: 'false',
          comment: 'bar footer column',
          position: '1'
        },
        'v-fc' => {
          id: 'v-fc',
          physical_name: 'f_baz',
          logical_name: 'F-BAZ',
          data_type_id: '5',
          size: '10',
          size: '2',
          nulable: 'true',
          default_value: '0.0',
          comment: 'baz footer column',
          position: '2'
        }
      }
    }
  end

  def valid_update_params
    {
      name: 'test',
      comment: "foo\nbar\nbaz",
      lock_version: '0',
      header_columns: {
        'v-ha' => {
          id: 'v-ha',
          physical_name: 'h_foo',
          logical_name: 'H-FOO',
          data_type_id: '12',
          size: '150',
          nullable: 'true',
          comment: 'foo header column',
          position: '0'
        },
        'v-hb' => {
          id: 'v-hb',
          physical_name: 'h_bar',
          logical_name: 'H-BAR',
          data_type_id: '21',
          default_value: 'false',
          comment: 'bar header column',
          position: '1'
        },
        'v-hc' => {
          id: 'v-hc',
          physical_name: 'h_baz',
          logical_name: 'H-BAZ',
          data_type_id: '5',
          size: '10',
          size: '2',
          nulable: 'true',
          default_value: '0.0',
          comment: 'baz header column',
          position: '2'
        }
      },
      footer_columns: {
        'v-fa' => {
          id: 'v-fa',
          physical_name: 'f_foo',
          logical_name: 'F-FOO',
          data_type_id: '12',
          size: '150',
          nullable: 'true',
          comment: 'foo footer column',
          position: '0'
        },
        'v-fb' => {
          id: 'v-fb',
          physical_name: 'f_bar',
          logical_name: 'F-BAR',
          data_type_id: '21',
          default_value: 'false',
          comment: 'bar footer column',
          position: '1'
        },
        'v-fc' => {
          id: 'v-fc',
          physical_name: 'f_baz',
          logical_name: 'F-BAZ',
          data_type_id: '5',
          size: '10',
          size: '2',
          nulable: 'true',
          default_value: '0.0',
          comment: 'baz footer column',
          position: '2'
        }
      }
    }
  end

  def assert_saved_column_set(id, params, ignore=nil)
    column_set = MxColumnSet.find(id)
    assert_equal params[:name], column_set.name
    assert_equal params[:comment].presence, column_set.comment
    [:header_columns, :footer_columns].each do |columns_sym|
      if params[columns_sym]
        assert_equal params[columns_sym].size, column_set.send(columns_sym).size
        params[columns_sym].each do |_, column_params|
          column = column_set.send(columns_sym).where(physical_name: column_params[:physical_name]).first
          assert column
          assert_equal column_params[:logical_name], column.logical_name
          assert_equal column_params[:data_type_id], column.data_type_id.to_s
          unless ignore == :"#{columns_sym.to_s.singularize}_size"
            if column_params[:size].present?
              assert_equal column_params[:size], column.size.to_s
            else
              assert_nil column.size
            end
          end
          unless ignore == :"#{columns_sym.to_s.singularize}_scale"
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
      else
        assert_equal 0, column_set.send(columns_sym).size
      end
    end
  end

  def assert_create_success(params, column_count=6)
    assert_difference 'MxColumnSet.count', 1 do
      assert_difference 'MxColumn.count', column_count do
        post :create, project_id: @project, database_id: @database, mx_column_set: params
      end
    end
    assert_response 302
    assert_redirected_to project_mx_database_column_set_path(@project, @database, 4)
  end

  def assert_create_failure(params)
    assert_no_difference 'MxColumnSet.count' do
      assert_no_difference 'MxColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_column_set: params
      end
    end
    assert_response :success
    assert_template 'new'
  end

  def assert_update_success(params, column_count)
    assert_no_difference 'MxColumnSet.count' do
      assert_difference 'MxColumn.count', column_count do
        put :update, project_id: @project, database_id: @database, id: 1, mx_column_set: params
      end
    end
    assert_response 302
    assert_redirected_to project_mx_database_column_set_path(@project, @database, 1)
  end

  def assert_update_failure(params)
    assert_no_difference 'MxColumnSet.count' do
      assert_no_difference 'MxColumn.count' do
        put :update, project_id: @project, database_id: @database, id: 1, mx_column_set: params
      end
    end
    assert_response :success
    assert_template 'edit'
  end

  def assert_have_error(attribute, error)
    if error.is_a?(Regexp)
      assert_match error, assigns(:vue_model).errors[attribute].first
    else
      assert_equal error, assigns(:vue_model).errors[attribute].first
    end
  end
end
