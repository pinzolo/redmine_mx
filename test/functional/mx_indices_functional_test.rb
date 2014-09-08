require File.expand_path('../../test_helper', __FILE__)

class MxIndicesFunctionalTest < ActionController::TestCase
  tests MxTablesController
  fixtures :users, :projects, :members, :roles, :member_roles,
           :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_column_sets, :mx_columns, :mx_tables,
           :mx_primary_keys, :mx_primary_key_columns, :mx_indices, :mx_index_columns

  def setup
    enable_mx!
    setup_mx_permissions!
    @project = Project.find('ecookbook')
    @database = MxDatabase.find_database(@project, 'main')
    by_manager
  end

  def test_destroy
    index_ids = MxIndex.where(table_id: 1).map(&:id)
    assert_difference 'MxIndex.count', -2 do
      assert_difference 'MxIndexColumn.count', -3 do
        delete :destroy, project_id: @project, database_id: @database, id: 1
      end
    end
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, @database)
    assert MxIndex.where(table_id: 1).empty?
    assert MxIndexColumn.where(index_id: index_ids).empty?
  end

  # create {{{

  def test_create_with_indices_params
    params = valid_create_params
    assert_create_success(params)
    assert_saved_indices(7, params)
  end

  def test_create_without_indices_params
    params = valid_create_params.tap { |p| p.delete(:indices) }
    assert_no_difference 'MxIndex.count' do
      assert_no_difference 'MxIndexColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(7)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.indices.empty?
  end

  def test_create_with_empty_indices_params
    params = valid_create_params.tap { |p| p[:indices] = {} }
    assert_no_difference 'MxIndex.count' do
      assert_no_difference 'MxIndexColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(7)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.indices.empty?
  end

  def test_create_without_index_name
    params = valid_create_params.tap { |p| p[:indices]['v-index1'].delete(:name) }
    assert_create_failure(params)
    assert_have_error(:index_name, "can't be blank")
  end

  def test_create_with_empty_index_name
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:name] = '' }
    assert_create_failure(params)
    assert_have_error(:index_name, "can't be blank")
  end

  def test_create_with_too_long_index_name
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:name] = 'a' * 256 }
    assert_create_failure(params)
    assert_have_error(:index_name, /is too long/)
  end

  def test_create_with_just_long_index_name
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:name] = 'a' * 255 }
    assert_create_success(params)
    assert_saved_indices(7, params)
  end

  def test_create_with_already_taken_index_name
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:name] = 'customers_idx1' }
    assert_create_failure(params)
    assert_have_error(:index_name, 'has already been taken')
  end

  def test_create_with_duplicated_index_name
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:name] = 'test_idx1' }
    assert_create_failure(params)
    assert_have_error(:index_name, 'has already been taken')
  end

  def test_create_with_already_taken_index_name_in_other_database
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:name] = 'books_idx1' }
    assert_create_success(params)
    assert_saved_indices(7, params)
  end

  def test_create_with_too_long_index_condition
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:condition] = 'a' * 256 }
    assert_create_failure(params)
    assert_have_error(:index_condition, /is too long/)
  end

  def test_create_with_just_long_index_condition
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:condition] = 'a' * 255 }
    assert_create_success(params)
    assert_saved_indices(7, params)
  end

  def test_create_without_index_columns
    params = valid_create_params.tap { |p| p[:indices]['v-index1'].delete(:columns) }
    assert_create_failure(params)
    assert_have_error(:index_columns, "can't be blank")
  end

  def test_create_with_empty_index_columns
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:columns] = {} }
    assert_create_failure(params)
    assert_have_error(:index_columns, "can't be blank")
  end

  def test_create_when_index_columns_contains_invalid_column_id_that_not_exist_in_table
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:columns] = {'6' => '0'} }
    assert_create_failure(params)
    assert_have_error(:index_column_column_id, 'is not included in the list')
  end

  def test_create_when_index_columns_contains_no_poision
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:columns] = {'1' => nil} }
    assert_create_failure(params)
    assert_have_error(:index_column_position, "can't be blank")
  end

  def test_create_when_index_columns_contains_not_number_poision
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:columns] = {'1' => 'a'} }
    assert_create_failure(params)
    assert_have_error(:index_column_position, 'is not a number')
  end

  def test_create_when_index_columns_one_origin_poision
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:columns] = {'1' => '1'} }
    assert_create_failure(params)
    assert_have_error(:index_column_position, 'is invalid')
  end

  def test_create_when_index_columns_contains_negative_poision
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:columns] = {'1' => '-1'} }
    assert_create_failure(params)
    assert_have_error(:index_column_position, 'must be greater than or equal to 0')
  end

  def test_create_when_index_columns_contains_invalid_poision_as_order
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:columns] = {'1' => '0', 'v-column1' => '3' } }
    assert_create_failure(params)
    assert_have_error(:index_column_position, 'is invalid')
  end

  def test_create_when_index_columns_contains_duplicated_poision
    params = valid_create_params.tap { |p| p[:indices]['v-index1'][:columns] = {'1' => '0', 'v-column1' => '0' } }
    assert_create_failure(params)
    assert_have_error(:index_column_position, 'is invalid')
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
      indices: {
        'v-index1' => { id: 'v-index1',
                        name: 'test_uk1',
                        unique: 'true',
                        condition: 'v-index1-condition',
                        comment: 'v-index1-comment',
                        columns: { '1' => '0' } },
        'v-index2' => { id: 'v-index2',
                        name: 'test_idx1',
                        columns: { 'v-column1' => '1', 'v-column3' => '0' } }
      }
    }
  end

  def assert_saved_indices(table_id, params)
    table = MxTable.find(table_id)
    assert_equal params[:indices].size, table.indices.size
    params[:indices].each do |_, index_params|
      index = table.indices.detect { |idx| idx.name == index_params[:name] }
      assert index
      assert_equal index_params[:unique].present?, index.unique
      assert_equal index_params[:condition], index.condition
      assert_equal index_params[:comment], index.comment
      assert_equal index_params[:columns].size, index.columns_rels.size
      index_params[:columns].each do |column_id, position|
        column_physical_name = table.column_set.columns.detect { |col| col.id.to_s == column_id }.try(:physical_name)
        column_physical_name ||= params[:table_columns][column_id][:physical_name]
        assert column_physical_name
        actual_column = table.columns.detect { |col| col.physical_name == column_physical_name }
        actual_position = index.columns_rels.detect { |rel| rel.column_id == actual_column.id }.try(:position)
        assert_equal position, actual_position.to_s
      end
    end
  end

  def assert_create_success(params, index_count = 2, column_count = 3)
    assert_difference 'MxIndex.count', index_count do
      assert_difference 'MxIndexColumn.count', column_count do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(7)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
  end

  def assert_create_failure(params)
    assert_no_difference 'MxIndex.count' do
      assert_no_difference 'MxIndexColumn.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response :success
    assert_template 'new'
  end
end
