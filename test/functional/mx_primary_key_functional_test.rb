require File.expand_path('../../test_helper', __FILE__)

class MxPrimaryKeyFunctionalTest < ActionController::TestCase
  tests MxTablesController
  fixtures :users, :projects, :members, :roles, :member_roles,
    :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_column_sets, :mx_columns, :mx_tables,
    :mx_primary_keys, :mx_primary_key_columns

  def setup
    enable_mx!
    setup_mx_permissions!
    @project = Project.find('ecookbook')
    @database = MxDatabase.find_database(@project, 'main')
    by_manager
  end

  # create {{{

  def test_create_with_primary_key_params
    assert_create_success(valid_create_params)
    table = MxTable.find(7)
    assert table.primary_key
    assert_equal 'test_pk', table.primary_key.name
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'id', table.primary_key.columns.first.physical_name
  end

  def test_create_without_primary_key_params
    params = valid_create_params.tap { |p| p.delete(:primary_key) }
    assert_no_difference 'MxPrimaryKey.count' do
      assert_no_difference 'MxPrimaryKeyColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(7)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.primary_key.nil?
  end

  def test_create_without_primary_key_name
    params = valid_create_params.tap { |p| p[:primary_key].delete(:name) }
    assert_create_success(params)
    table = MxTable.find(7)
    assert table.primary_key
    assert table.primary_key.name.nil?
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'id', table.primary_key.columns.first.physical_name
  end

  def test_create_with_empty_primary_key_name
    params = valid_create_params.tap { |p| p[:primary_key][:name] = '' }
    assert_create_success(params)
    table = MxTable.find(7)
    assert table.primary_key
    assert table.primary_key.name.blank?
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'id', table.primary_key.columns.first.physical_name
  end

  def test_create_with_too_long_primary_key_name
    params = valid_create_params.tap { |p| p[:primary_key][:name] = 'a' * 256 }
    assert_create_failure(params)
    assert_have_error(:primary_key_name, /is too long/)
  end

  def test_create_with_just_long_primary_key_name
    params = valid_create_params.tap { |p| p[:primary_key][:name] = 'a' * 255 }
    assert_create_success(params)
    table = MxTable.find(7)
    assert table.primary_key
    assert_equal 'a' * 255, table.primary_key.name
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'id', table.primary_key.columns.first.physical_name
  end

  def test_create_with_already_taken_primary_key_name
    params = valid_create_params.tap { |p| p[:primary_key][:name] = 'customers_pk' }
    assert_create_failure(params)
    assert_have_error(:primary_key_name, 'has already been taken')
  end

  def test_create_with_primary_key_name_but_no_primary_key_columns
    params = valid_create_params.tap { |p| p[:primary_key].delete(:columns) }
    assert_no_difference 'MxPrimaryKey.count' do
      assert_no_difference 'MxPrimaryKeyColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(7)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.primary_key.nil?
  end

  def test_create_with_primary_key_name_but_empty_primary_key_columns
    params = valid_create_params.tap { |p| p[:primary_key][:columns] = {} }
    assert_no_difference 'MxPrimaryKey.count' do
      assert_no_difference 'MxPrimaryKeyColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(7)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.primary_key.nil?
  end

  def test_create_with_multi_primary_key_columns
    params = valid_create_params.tap { |p| p[:primary_key][:columns] = { '1' => '1', 'v-column1' => '2' } }
    assert_create_success(params, 2)
    table = MxTable.find(7)
    assert table.primary_key
    assert_equal 'test_pk', table.primary_key.name
    assert_equal 2, table.primary_key.columns.size
    assert_equal ['id', 'foo'], table.primary_key.columns.map(&:physical_name)
  end

  def test_create_when_primary_key_columns_contains_invalid_column_id_that_not_exist_in_table
    params = valid_create_params.tap { |p| p[:primary_key][:columns] = { '6' => '1' } }
    assert_create_failure(params)
    assert_have_error(:primary_key_column_column_id, 'is not included in the list')
  end

  def test_create_when_primary_key_columns_contains_no_poision
    params = valid_create_params.tap { |p| p[:primary_key][:columns] = { '1' => nil } }
    assert_create_failure(params)
    assert_have_error(:primary_key_column_position, "can't be blank")
  end

  def test_create_when_primary_key_columns_contains_not_number_poision
    params = valid_create_params.tap { |p| p[:primary_key][:columns] = { '1' => 'a' } }
    assert_create_failure(params)
    assert_have_error(:primary_key_column_position, 'is not a number')
  end

  def test_create_when_primary_key_columns_contains_zero_poision
    params = valid_create_params.tap { |p| p[:primary_key][:columns] = { '1' => '0' } }
    assert_create_failure(params)
    assert_have_error(:primary_key_column_position, 'must be greater than 0')
  end

  def test_create_when_primary_key_columns_contains_negative_poision
    params = valid_create_params.tap { |p| p[:primary_key][:columns] = { '1' => '-1' } }
    assert_create_failure(params)
    assert_have_error(:primary_key_column_position, 'must be greater than 0')
  end

  def test_create_when_primary_key_columns_contains_invalid_poision_as_order
    params = valid_create_params.tap { |p| p[:primary_key][:columns] = { '1' => '1', 'v-column1' => '3' } }
    assert_create_failure(params)
    assert_have_error(:primary_key_column_position, 'is invalid')
  end

  def test_create_when_primary_key_columns_contains_duplicated_poision
    params = valid_create_params.tap { |p| p[:primary_key][:columns] = { '1' => '1', 'v-column1' => '1' } }
    assert_create_failure(params)
    assert_have_error(:primary_key_column_position, 'is invalid')
  end

  # }}}

  # update {{{

  def test_update_with_primary_key_params
    assert_update_success(valid_update_params, 4)
    table = MxTable.find(4)
    assert table.primary_key
    assert_equal 'test_pk', table.primary_key.name
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'serial_no', table.primary_key.columns.first.physical_name
  end

  def test_update_without_primary_key_params_on_already_have_primary_key_table
    params = valid_update_params.tap { |p| p.delete(:primary_key) }
    assert_difference 'MxPrimaryKey.count', -1 do
      assert_difference 'MxPrimaryKeyColumn.count', -2 do
        table = MxTable.find(4)
        put :update, project_id: @project, database_id: @database, id: table, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(4)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.primary_key.nil?
  end

  def test_update_without_primary_key_name
    params = valid_update_params.tap { |p| p[:primary_key].delete(:name) }
    assert_update_success(params, 4)
    table = MxTable.find(4)
    assert table.primary_key
    assert table.primary_key.name.nil?
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'serial_no', table.primary_key.columns.first.physical_name
  end

  def test_update_with_empty_primary_key_name
    params = valid_update_params.tap { |p| p[:primary_key][:name] = '' }
    assert_update_success(params, 4)
    table = MxTable.find(4)
    assert table.primary_key
    assert table.primary_key.name.blank?
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'serial_no', table.primary_key.columns.first.physical_name
  end

  def test_update_with_too_long_primary_key_name
    params = valid_update_params.tap { |p| p[:primary_key][:name] = 'a' * 256 }
    assert_update_failure(params, 4)
    assert_have_error(:primary_key_name, /is too long/)
  end

  def test_update_with_just_long_primary_key_name
    params = valid_update_params.tap { |p| p[:primary_key][:name] = 'a' * 255 }
    assert_update_success(params, 4)
    table = MxTable.find(4)
    assert table.primary_key
    assert_equal 'a' * 255, table.primary_key.name
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'serial_no', table.primary_key.columns.first.physical_name
  end

  def test_update_with_same_primary_key_name
    params = valid_update_params.tap { |p| p[:primary_key][:name] = 'order_items_pk' }
    assert_update_success(params, 4)
    table = MxTable.find(4)
    assert table.primary_key
    assert_equal 'order_items_pk', table.primary_key.name
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'serial_no', table.primary_key.columns.first.physical_name
  end

  def test_update_with_already_taken_primary_key_name_in_other_table
    params = valid_update_params.tap { |p| p[:primary_key][:name] = 'customers_pk' }
    assert_update_failure(params, 4)
    assert_have_error(:primary_key_name, 'has already been taken')
  end

  def test_update_with_already_taken_primary_key_name_in_other_database
    params = valid_update_params.tap { |p| p[:primary_key][:name] = 'books_pk' }
    assert_update_success(params, 4)
    table = MxTable.find(4)
    assert table.primary_key
    assert_equal 'books_pk', table.primary_key.name
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'serial_no', table.primary_key.columns.first.physical_name
  end

  def test_update_with_primary_key_name_but_no_primary_key_columns
    params = valid_update_params.tap { |p| p[:primary_key].delete(:columns) }
    assert_difference 'MxPrimaryKey.count', -1 do
      assert_difference 'MxPrimaryKeyColumn.count', -2 do
        table = MxTable.find(4)
        put :update, project_id: @project, database_id: @database, id: table, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(4)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.primary_key.nil?
  end

  def test_update_with_primary_key_name_but_empty_primary_key_columns
    params = valid_update_params.tap { |p| p[:primary_key][:columns] = {} }
    assert_difference 'MxPrimaryKey.count', -1 do
      assert_difference 'MxPrimaryKeyColumn.count', -2 do
        table = MxTable.find(4)
        put :update, project_id: @project, database_id: @database, id: table, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(4)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.primary_key.nil?
  end

  def test_update_with_same_primary_key_columns
    params = valid_update_params.tap { |p| p[:primary_key][:columns] = { '23' => '1', '24' => '2' } }
    assert_no_difference 'MxPrimaryKey.count' do
      assert_no_difference 'MxPrimaryKeyColumn.count' do
        table = MxTable.find(4)
        put :update, project_id: @project, database_id: @database, id: table, mx_table: params
      end
    end
    table = MxTable.find(4)
    assert table.primary_key
    assert_equal 'test_pk', table.primary_key.name
    assert_equal 2, table.primary_key.columns.size
    assert_equal ['order_id', 'item_id'], table.primary_key.columns.map(&:physical_name)
  end

  def test_update_when_primary_key_columns_contains_invalid_column_id_that_not_exist_in_table
    params = valid_update_params.tap { |p| p[:primary_key][:columns] = { '6' => '1' } }
    assert_update_failure(params, 4)
    assert_have_error(:primary_key_column_column_id, 'is not included in the list')
  end

  def test_update_when_primary_key_columns_contains_no_poision
    params = valid_update_params.tap { |p| p[:primary_key][:columns] = { '23' => nil } }
    assert_update_failure(params, 4)
    assert_have_error(:primary_key_column_position, "can't be blank")
  end

  def test_update_when_primary_key_columns_contains_not_number_poision
    params = valid_update_params.tap { |p| p[:primary_key][:columns] = { '23' => 'a' } }
    assert_update_failure(params, 4)
    assert_have_error(:primary_key_column_position, 'is not a number')
  end

  def test_update_when_primary_key_columns_contains_zero_poision
    params = valid_update_params.tap { |p| p[:primary_key][:columns] = { '23' => '0' } }
    assert_update_failure(params, 4)
    assert_have_error(:primary_key_column_position, 'must be greater than 0')
  end

  def test_update_when_primary_key_columns_contains_negative_poision
    params = valid_update_params.tap { |p| p[:primary_key][:columns] = { '23' => '-1' } }
    assert_update_failure(params, 4)
    assert_have_error(:primary_key_column_position, 'must be greater than 0')
  end

  def test_update_when_primary_key_columns_contains_invalid_poision_as_order
    params = valid_update_params.tap { |p| p[:primary_key][:columns] = { '23' => '1', 'v-column1' => '3' } }
    assert_update_failure(params, 4)
    assert_have_error(:primary_key_column_position, 'is invalid')
  end

  def test_update_when_primary_key_columns_contains_duplicated_poision
    params = valid_update_params.tap { |p| p[:primary_key][:columns] = { '23' => '1', 'v-column1' => '1' } }
    assert_update_failure(params, 4)
    assert_have_error(:primary_key_column_position, 'is invalid')
  end

  def test_update_table_that_have_not_have_primary_key_table
    assert_difference 'MxPrimaryKey.count', 1 do
      assert_difference 'MxPrimaryKeyColumn.count', 1 do
        table = MxTable.find(5)
        put :update, project_id: @project, database_id: @database, id: table, mx_table: valid_update_params_for_prefectures
      end
    end
    table = MxTable.find(5)
    assert table.primary_key
    assert_equal 'prefectures_pk', table.primary_key.name
    assert_equal 1, table.primary_key.columns.size
    assert_equal 'id', table.primary_key.columns.first.physical_name
  end

  # }}}

  def test_destroy
    primary_key_id = MxPrimaryKey.where(table_id: 4).first.id
    assert_difference 'MxPrimaryKey.count', -1 do
      assert_difference 'MxPrimaryKeyColumn.count', -2 do
        delete :destroy, project_id: @project, database_id: @database, id: 4
      end
    end
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, @database)
    assert MxPrimaryKey.where(table_id: 4).empty?
    assert MxPrimaryKeyColumn.where(primary_key_id: primary_key_id).empty?
  end

  private

  def valid_create_params
    {
      physical_name: 'test',
      logical_name: 'Test table',
      comment: "foo\nbar\nbaz",
      column_set_id: '1',
      table_columns: {
        'v-column1' => { id: 'v-column1',
                         physical_name: 'foo',
                         logical_name: 'FOO',
                         data_type_id: '12',
                         size: '150',
                         nullable: 'true',
                         comment: 'foo column',
                         position: '0' },
        'v-column2' => { id: 'v-column2',
                         physical_name: 'bar',
                         logical_name: 'BAR',
                         data_type_id: '21',
                         default_value: 'false',
                         comment: 'bar column',
                         position: '1' },
        'v-column3' => { id: 'v-column3',
                         physical_name: 'baz',
                         logical_name: 'BAZ',
                         data_type_id: '5',
                         size: '10',
                         size: '2',
                         nulable: 'true',
                         default_value: '0.0',
                         comment: 'baz column',
                         position: '2' }
      },
      primary_key: { name: 'test_pk',
                     columns: { '1' => '1' } }
    }
  end

  def valid_update_params
    {
      physical_name: 'test',
      logical_name: 'Test table',
      comment: "foo\nbar\nbaz",
      column_set_id: nil,
      lock_version: '0',
      table_columns: {
        'v-column1' => { id: 'v-column1',
                         physical_name: 'serial_no',
                         logical_name: 'Unique ID',
                         data_type_id: '8',
                         size: '',
                         comment: 'Use for printing to reciept',
                         position: '0' },
        '23' => { id: '23',
                  physical_name: 'order_id',
                  logical_name: 'Belonging order ID',
                  data_type_id: '2',
                  size: '',
                  scale: '',
                  default_value: '',
                  position: '1' },
        '24' => { id: '24',
                  physical_name: 'item_id',
                  logical_name: 'ID of bought item',
                  data_type_id: '2',
                  size: '',
                  scale: '',
                  default_value: '',
                  position: '2' },
        '25' => { id: '25',
                  physical_name: 'amount',
                  logical_name: 'Amount per bought item',
                  data_type_id: '2',
                  size: '',
                  scale: '',
                  default_value: '1',
                  comment: 'Allowed greater than 1',
                  position: '3' },
      },
      primary_key: { name: 'test_pk',
                     columns: { 'v-column1' => '1' }
      }
    }
  end

  def valid_update_params_for_prefectures
    {
      physical_name: 'prefectrues',
      logical_name: 'Prefectures',
      column_set_id: '1',
      lock_version: '0',
      table_columns: {
        '26' => { id: '26',
                  physical_name: 'code',
                  logical_name: 'Code',
                  data_type_id: '11',
                  size: '2',
                  scale: '',
                  default_value: '',
                  position: '0' },
        '27' => { id: '27',
                  physical_name: 'name',
                  logical_name: 'Prefecture name',
                  data_type_id: '12',
                  size: '4',
                  scale: '',
                  default_value: '',
                  position: '1' }
      },
      primary_key: { name: 'prefectures_pk',
                     columns: { '1' => '1' }
      }
    }
  end

  def assert_create_success(params, column_count = 1)
    assert_difference 'MxPrimaryKey.count', 1 do
      assert_difference 'MxPrimaryKeyColumn.count', column_count do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(7)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
  end

  def assert_create_failure(params)
    assert_no_difference 'MxPrimaryKey.count' do
      assert_no_difference 'MxPrimaryKeyColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response :success
    assert_template 'new'
  end

  def assert_update_success(params, table_id, column_count = -1)
    table = MxTable.find(table_id)
    assert_no_difference 'MxPrimaryKey.count' do
      assert_difference 'MxPrimaryKeyColumn.count', column_count do
        put :update, project_id: @project, database_id: @database, id: table, mx_table: params
      end
    end
    table.reload
    assert_response 302
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
  end

  def assert_update_failure(params, table_id)
    table = MxTable.find(table_id)
    assert_no_difference 'MxPrimaryKey.count' do
      assert_no_difference 'MxPrimaryKeyColumn.count' do
        put :update, project_id: @project, database_id: @database, id: table, mx_table: params
      end
    end
    assert_response :success
    assert_template 'edit'
  end
end
