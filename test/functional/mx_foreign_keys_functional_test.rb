require File.expand_path('../../test_helper', __FILE__)

class MxForeignKeysFunctionalTest < ActionController::TestCase
  tests MxTablesController
  fixtures :users, :projects, :members, :roles, :member_roles,
           :mx_dbms_products, :mx_data_types, :mx_comments, :mx_databases, :mx_column_sets, :mx_columns, :mx_tables,
           :mx_primary_keys, :mx_primary_key_columns, :mx_indices, :mx_index_columns, :mx_foreign_keys, :mx_foreign_key_relations

  def setup
    enable_mx!
    setup_mx_permissions!
    @project = Project.find('ecookbook')
    @database = MxDatabase.find_database(@project, 'main')
    by_manager
  end

  def test_destroy
    foreign_key_ids = MxForeignKey.where(table_id: 4).map(&:id)
    assert_difference 'MxForeignKey.count', -2 do
      assert_difference 'MxForeignKeyRelation.count', -2 do
        delete :destroy, project_id: @project, database_id: @database, id: 4
      end
    end
    assert_response 302
    assert_redirected_to project_mx_database_tables_path(@project, @database)
    assert MxForeignKey.where(table_id: 4).empty?
    assert MxForeignKeyRelation.where(foreign_key_id: foreign_key_ids).empty?
  end

  # create {{{

  NEXT_TABLE_ID = 7

  def test_create_with_foreign_keys_params
    params = valid_create_params
    assert_create_success(params)
    assert_saved_foreign_keys(NEXT_TABLE_ID, params)
  end

  def test_create_without_foreign_keys_params
    params = valid_create_params.tap { |p| p.delete(:foreign_keys) }
    assert_no_difference 'MxForeignKey.count' do
      assert_no_difference 'MxForeignKeyRelation.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(NEXT_TABLE_ID)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.foreign_keys.empty?
  end

  def test_create_with_empty_foreign_keys_params
    params = valid_create_params.tap { |p| p[:foreign_keys] = {} }
    assert_no_difference 'MxForeignKey.count' do
      assert_no_difference 'MxForeignKeyRelation.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(NEXT_TABLE_ID)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.foreign_keys.empty?
  end

  def test_create_without_foreign_key_name
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'].delete(:name) }
    assert_create_failure(params)
    assert_have_error(:foreign_key_name, "can't be blank")
  end

  def test_create_with_empty_foreign_key_name
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = '' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_name, "can't be blank")
  end

  def test_create_with_too_long_foreign_key_name
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'a' * 256 }
    assert_create_failure(params)
    assert_have_error(:foreign_key_name, /is too long/)
  end

  def test_create_with_just_long_foreign_key_name
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'a' * 255 }
    assert_create_success(params)
    assert_saved_foreign_keys(NEXT_TABLE_ID, params)
  end

  def test_create_with_already_taken_foreign_key_name
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'customers_fk1' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_name, 'has already been taken')
  end

  def test_create_with_duplicated_foreign_key_name
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'test_fk2' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_name, 'has already been taken')
  end

  def test_create_without_ref_table_id
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'].delete(:ref_table_id) }
    assert_create_failure(params)
    assert_have_error(:foreign_key_ref_table_id, 'is not included in the list')
  end

  def test_create_with_empty_ref_table_id
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:ref_table_id] = '' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_ref_table_id, 'is not included in the list')
  end

  def test_create_with_ref_table_id_not_exist
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:ref_table_id] = '0' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_ref_table_id, 'is not included in the list')
  end

  # TODO: Add data
  # def test_create_with_already_taken_foreign_key_name_in_other_database
  #   params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'books_fk1' }
  #   assert_create_success(params)
  #   assert_saved_foreign_keys(NEXT_TABLE_ID, params)
  # end

  def test_create_without_foreign_key_relations
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'].delete(:relations) }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relations, "can't be blank")
  end

  def test_create_with_empty_foreign_key_relations
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations] = {} }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relations, "can't be blank")
  end

  def test_create_without_foreign_key_relation_column_id
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'].delete(:column_id) }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_column_id, "can't be blank")
  end

  def test_create_with_empty_foreign_key_relation_column_id
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:column_id] = '' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_column_id, "can't be blank")
  end

  def test_create_when_foreign_key_relations_contains_invalid_column_id_that_not_exist_in_table
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:column_id] = '0' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_column_id, 'is not included in the list')
  end

  def test_create_without_foreign_key_relation_position
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'].delete(:position) }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_position, "can't be blank")
  end

  def test_create_with_empty_foreign_key_relation_position
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:position] = '' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_position, "can't be blank")
  end

  def test_create_with_not_number_foreign_key_relation_position
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:position] = 'a' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_position, 'is not a number')
  end

  def test_create_with_duplicated_foreign_key_relation_position
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk2'][:relations]['v-fk2-rel2'][:position] = '0' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_position, 'is invalid')
  end

  def test_create_with_one_origin_foreign_key_relation_poision
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:position] = '1' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_position, 'is invalid')
  end

  def test_create_without_foreign_key_relation_ref_column_id
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'].delete(:ref_column_id) }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_ref_column_id, "can't be blank")
  end

  def test_create_with_empty_foreign_key_relation_ref_column_id
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:ref_column_id] = '' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_ref_column_id, "can't be blank")
  end

  def test_create_when_foreign_key_relations_contains_invalid_ref_column_id_that_not_exist_in_ref_table
    params = valid_create_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:ref_column_id] = '0' }
    assert_create_failure(params)
    assert_have_error(:foreign_key_relation_ref_column_id, 'is not included in the list')
  end

  # }}}

  # update {{{

  def test_update_with_foreign_keys_params
    params = valid_update_params
    assert_update_success(params)
    assert_saved_foreign_keys(1, params)
  end

  def test_update_without_foreign_keys_params
    foreign_key_ids = MxTable.find(1).foreign_keys.map(&:id)
    params = valid_update_params.tap { |p| p.delete(:foreign_keys) }
    assert_difference 'MxForeignKey.count', -1 do
      assert_difference 'MxForeignKeyRelation.count', -1 do
        put :update, project_id: @project, database_id: @database, id: 'customers', mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(1)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.foreign_keys.empty?
    assert MxForeignKey.where(table_id: 1).empty?
    assert MxForeignKeyRelation.where(foreign_key_id: foreign_key_ids).empty?
  end

  def test_update_without_foreign_keys_params
    params = valid_update_params.tap { |p| p[:foreign_keys] = {} }
    assert_difference 'MxForeignKey.count', -1 do
      assert_difference 'MxForeignKeyRelation.count', -1 do
        put :update, project_id: @project, database_id: @database, id: 'customers', mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(1)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
    assert table.foreign_keys.empty?
  end

  def test_update_without_foreign_key_name
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'].delete(:name) }
    assert_update_failure(params)
    assert_have_error(:foreign_key_name, "can't be blank")
  end

  def test_update_with_empty_foreign_key_name
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = '' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_name, "can't be blank")
  end

  def test_update_with_too_long_foreign_key_name
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'a' * 256 }
    assert_update_failure(params)
    assert_have_error(:foreign_key_name, /is too long/)
  end

  def test_update_with_just_long_foreign_key_name
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'a' * 255 }
    assert_update_success(params)
    assert_saved_foreign_keys(1, params)
  end

  def test_update_with_already_taken_foreign_key_name
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'order_items_fk1' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_name, 'has already been taken')
  end

  def test_update_with_same_foreign_key_name
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'customers_fk1' }
    assert_update_success(params)
    assert_saved_foreign_keys(1, params)
  end

  def test_update_with_duplicated_foreign_key_name
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'test_fk2' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_name, 'has already been taken')
  end

  def test_update_without_ref_table_id
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'].delete(:ref_table_id) }
    assert_update_failure(params)
    assert_have_error(:foreign_key_ref_table_id, 'is not included in the list')
  end

  def test_update_with_empty_ref_table_id
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:ref_table_id] = '' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_ref_table_id, 'is not included in the list')
  end

  def test_update_with_ref_table_id_not_exist
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:ref_table_id] = '0' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_ref_table_id, 'is not included in the list')
  end

  # TODO: Add data
  # def test_update_with_already_taken_foreign_key_name_in_other_database
  #  params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:name] = 'books_fk1' }
  #  assert_update_failure(params)
  #  assert_saved_foreign_keys(1, params)
  # end

  def test_update_without_foreign_key_relations
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'].delete(:relations) }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relations, "can't be blank")
  end

  def test_update_with_empty_foreign_key_relations
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations] = {} }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relations, "can't be blank")
  end

  def test_update_without_foreign_key_relation_column_id
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'].delete(:column_id) }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_column_id, "can't be blank")
  end

  def test_update_with_empty_foreign_key_relation_column_id
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:column_id] = '' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_column_id, "can't be blank")
  end

  def test_update_when_foreign_key_relations_contains_invalid_column_id_that_not_exist_in_table
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:column_id] = '0' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_column_id, 'is not included in the list')
  end

  def test_update_without_foreign_key_relation_position
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'].delete(:position) }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_position, "can't be blank")
  end

  def test_update_with_empty_foreign_key_relation_position
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:position] = '' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_position, "can't be blank")
  end

  def test_update_with_not_number_foreign_key_relation_position
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:position] = 'a' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_position, 'is not a number')
  end

  def test_update_with_duplicated_foreign_key_relation_position
    params = valid_update_params.tap { |p| p[:foreign_keys]['3'][:relations]['v-fk2-rel1'][:position] = '0' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_position, 'is invalid')
  end

  def test_update_with_one_origin_foreign_key_relation_poision
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:position] = '1' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_position, 'is invalid')
  end

  def test_update_without_foreign_key_relation_ref_column_id
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'].delete(:ref_column_id) }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_ref_column_id, "can't be blank")
  end

  def test_update_with_empty_foreign_key_relation_ref_column_id
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:ref_column_id] = '' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_ref_column_id, "can't be blank")
  end

  def test_update_when_foreign_key_relations_contains_invalid_ref_column_id_that_not_exist_in_ref_table
    params = valid_update_params.tap { |p| p[:foreign_keys]['v-fk1'][:relations]['v-fk1-rel1'][:ref_column_id] = '0' }
    assert_update_failure(params)
    assert_have_error(:foreign_key_relation_ref_column_id, 'is not included in the list')
  end

  #} }}

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
      foreign_keys: {
        'v-fk1' => { id: 'v-fk1',
                     name: 'test_fk1',
                     ref_table_id: '2',
                     comment: 'v-fk1-comment',
                     relations: {
                       'v-fk1-rel1' => {
                         id: 'v-fk-rel1',
                         column_id: 'v-column1',
                         ref_column_id: '1',
                         position: '0'
                       }
                     }
        },
        'v-fk2' => { id: 'v-fk2',
                     name: 'test_fk2',
                     ref_table_id: '1',
                     comment: 'v-fk2-comment',
                     relations: {
                       'v-fk2-rel1' => {
                         id: 'v-fk-rel1',
                         column_id: 'v-column2',
                         ref_column_id: '12',
                         position: '0'
                       },
                       'v-fk2-rel2' => {
                         id: 'v-fk-rel2',
                         column_id: 'v-column3',
                         ref_column_id: '13',
                         position: '1'
                       }
                     }
        }
      }
    }
  end

  def valid_update_params
    {
      physical_name: 'test',
      logical_name: 'Test table',
      comment: "foo\nbar\nbaz",
      column_set_id: '1',
      table_columns: {
        '12' => { id: '12',
                  physical_name: 'name',
                  logical_name: 'Customer name',
                  data_type_id: '12',
                  size: '64',
                  scale: '',
                  default_value: '',
                  position: '0' },
        '13' => { id: '13',
                  physical_name: 'birthday',
                  logical_name: 'Birthday',
                  data_type_id: '17',
                  size: '',
                  scale: '',
                  nullable: 'true',
                  default_value: '',
                  position: '1' },
        '14' => { id: '14',
                  physical_name: 'zip_code',
                  logical_name: 'ZIP code of address',
                  data_type_id: '11',
                  size: '8',
                  scale: '',
                  nullable: 'true',
                  default_value: '',
                  position: '2' },
        '15' => { id: '15',
                  physical_name: 'prefecture_id',
                  logical_name: 'Prefecture ID of address',
                  data_type_id: '2',
                  size: '',
                  scale: '',
                  nullable: 'true',
                  default_value: '',
                  position: '3' },
        '16' => { id: '16',
                  physical_name: 'address',
                  logical_name: "Customer's address",
                  data_type_id: '12',
                  size: '255',
                  scale: '',
                  nullable: 'true',
                  default_value: '',
                  position: '4' },
        '17' => { id: '17',
                  physical_name: 'registered_on',
                  logical_name: 'Date of registration',
                  data_type_id: '17',
                  size: '',
                  scale: '',
                  default_value: 'current_date',
                  position: '5' },
        '18' => { id: '18',
                  physical_name: 'unregistered_on',
                  logical_name: 'Date of unregistration',
                  data_type_id: '17',
                  size: '',
                  scale: '',
                  nullable: 'true',
                  default_value: '',
                  position: '6' },
        'v-column1' => { id: 'v-column1',
                         physical_name: 'foo',
                         logical_name: 'FOO',
                         data_type_id: '12',
                         size: '150',
                         nullable: 'true',
                         comment: 'foo column',
                         position: '0' },
      },
      foreign_keys: {
        'v-fk1' => { id: 'v-fk1',
                     name: 'test_fk1',
                     ref_table_id: '2',
                     comment: 'v-fk1-comment',
                     relations: {
                       'v-fk1-rel1' => {
                         id: 'v-fk-rel1',
                         column_id: '13',
                         ref_column_id: '1',
                         position: '0' }
                     }
        },
        '3' => { id: '3',
                 name: 'test_fk2',
                 ref_table_id: '3',
                 comment: 'v-fk2-comment',
                 relations: {
                   '3' => {
                     id: '3',
                     column_id: '15',
                     ref_column_id: '1',
                     position: '0' },
                   'v-fk2-rel1' => {
                     id: 'v-fk-rel1',
                     column_id: 'v-column1',
                     ref_column_id: '21',
                     position: '1' }
                 }
        }
      }
    }
  end

  def assert_saved_foreign_keys(table_id, params)
    table = MxTable.find(table_id)
    assert_equal params[:foreign_keys].size, table.foreign_keys.size
    params[:foreign_keys].each do |_, foreign_key_params|
      foreign_key = table.foreign_keys.detect { |fk| fk.name == foreign_key_params[:name] }
      assert foreign_key
      assert_equal foreign_key_params[:comment], foreign_key.comment
      assert_equal foreign_key_params[:ref_table_id], foreign_key.ref_table_id.to_s
      assert_equal foreign_key_params[:relations].size, foreign_key.relations.size
      foreign_key_params[:relations].each do |relation_id, relation_params|
        # column
        column_physical_name = table.column_set.columns.detect { |col| col.id.to_s == relation_params[:column_id] }.try(:physical_name)
        column_physical_name ||= params[:table_columns][relation_params[:column_id]][:physical_name]
        assert column_physical_name
        actual_column = table.columns.detect { |col| col.physical_name == column_physical_name }

        # ref_column
        ref_column = foreign_key.ref_table.columns.detect { |col| col.id.to_s == relation_params[:ref_column_id] }
        assert ref_column

        # position
        actual_position = foreign_key.relations.detect { |rel| rel.column_id == actual_column.id }.try(:position)
        assert_equal relation_params[:position], actual_position.to_s
      end
    end
  end

  def assert_create_success(params, foreign_key_count = 2, relation_count = 3)
    assert_difference 'MxForeignKey.count', foreign_key_count do
      assert_difference 'MxForeignKeyRelation.count', relation_count do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(NEXT_TABLE_ID)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
  end

  def assert_create_failure(params)
    assert_no_difference 'MxForeignKey.count' do
      assert_no_difference 'MxForeignKeyRelation.count' do
        post :create, project_id: @project, database_id: @database, mx_table: params
      end
    end
    assert_response :success
    assert_template 'new'
  end

  def assert_update_success(params, foreign_key_count = 1, relation_count = 2)
    assert_difference 'MxForeignKey.count', foreign_key_count do
      assert_difference 'MxForeignKeyRelation.count', relation_count do
        put :update, project_id: @project, database_id: @database, id: 'customers', mx_table: params
      end
    end
    assert_response 302
    table = MxTable.find(1)
    assert_redirected_to project_mx_database_table_path(@project, @database, table)
  end

  def assert_update_failure(params)
    assert_no_difference 'MxForeignKey.count' do
      assert_no_difference 'MxForeignKeyRelation.count' do
        put :update, project_id: @project, database_id: @database, id: 'customers', mx_table: params
      end
    end
    assert_response :success
    assert_template 'edit'
  end
end
