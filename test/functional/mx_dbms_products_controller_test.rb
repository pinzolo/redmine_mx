require File.expand_path('../../test_helper', __FILE__)

class MxDbmsProductsControllerTest < ActionController::TestCase
  fixtures :users, :mx_dbms_products, :mx_data_types

  def setup
    User.current = nil
  end

  def test_index_by_admin
    by_admin
    get :index
    assert_response :success
    assert_template 'index'
    dbms_products = assigns(:dbms_products)
    assert dbms_products.size == 5
    assert_tag tag: 'p', attributes: { id: 'mx-dbms-products' }
    assert_tag tag: 'div', attributes: { id: 'admin-menu' }
    assert_tag tag: 'a', attributes: { href: new_mx_dbms_product_path }
  end

  def test_index_by_not_admin
    by_not_admin
    get :index
    assert_response :success
    assert_template 'index'
    dbms_products = assigns(:dbms_products)
    assert dbms_products.size == 5
    assert_tag tag: 'p', attributes: { id: 'mx-dbms-products' }
    assert_no_tag tag: 'div', attributes: { id: 'admin-menu' }
    assert_no_tag tag: 'a', attributes: { href: new_mx_dbms_product_path }
  end

  def test_index_by_anonymous
    get :index
    assert_response 302
    assert_redirected_to '/login?back_url=http%3A%2F%2Ftest.host%2Fmx%2Fdbms_products'
  end

  def test_index_when_dbms_products_not_exists
    MxDbmsProduct.delete_all
    by_admin
    get :index
    assert_response :success
    assert_template 'index'
    dbms_products = assigns(:dbms_products)
    assert dbms_products.empty?
    assert_tag tag: 'p', attributes: { class: 'nodata' }
  end

  def test_show_by_admin
    by_admin
    get :show, id: 1
    assert_response :success
    assert_template 'show'
    dbms_product = assigns(:dbms_product)
    assert_equal 'PostgreSQL', dbms_product.name
    assert_equal  21, dbms_product.data_types.size
    assert_tag tag: 'p', attributes: { id: 'mx-dbms-product' }
    assert_tag tag: 'p', attributes: { id: 'mx-data-types' }
    assert_tag tag: 'div', attributes: { id: 'admin-menu' }
    assert_tag tag: 'a', attributes: { href: mx_dbms_products_path }
    assert_tag tag: 'a', attributes: { href: edit_mx_dbms_product_path(dbms_product) }
    assert_tag tag: 'a', attributes: { href: mx_dbms_product_path(dbms_product), 'data-method' => 'delete' }
  end

  def test_show_by_not_admin
    by_not_admin
    get :show, id: 1
    assert_response :success
    assert_template 'show'
    dbms_product = assigns(:dbms_product)
    assert_equal 'PostgreSQL', dbms_product.name
    assert_equal  21, dbms_product.data_types.size
    assert_tag tag: 'p', attributes: { id: 'mx-dbms-product' }
    assert_tag tag: 'p', attributes: { id: 'mx-data-types' }
    assert_no_tag tag: 'div', attributes: { id: 'admin-menu' }
    assert_tag tag: 'a', attributes: { href: mx_dbms_products_path }
    assert_no_tag tag: 'a', attributes: { href: edit_mx_dbms_product_path(dbms_product) }
    assert_no_tag tag: 'a', attributes: { href: mx_dbms_product_path(dbms_product), 'data-method' => 'delete' }
  end

  def test_show_by_anonymous
    get :show, id: 1
    assert_response 302
    assert_redirected_to '/login?back_url=http%3A%2F%2Ftest.host%2Fmx%2Fdbms_products%2F1'
  end

  def test_show_with_invalid_dbms_product_id
    by_admin
    get :show, id: 99
    assert_response 404
  end

  def test_destroy_by_admin
    by_admin
    assert_difference 'MxDbmsProduct.count', -1 do
      delete :destroy, id: 1
    end
    assert_redirected_to mx_dbms_products_path
    assert !MxDbmsProduct.where(id: 1).exists?
  end

  def test_destroy_by_not_admin
    by_not_admin
    delete :destroy, id: 1
    assert_response 403
  end

  def test_destroy_by_anonymous
    delete :destroy, id: 1
    assert_response 302
    assert_redirected_to '/login?back_url=http%3A%2F%2Ftest.host%2Fmx%2Fdbms_products%2F1'
  end

  def test_new_by_admin
    by_admin
    get :new
    assert_response :success
    assert_template 'new'
    dbms_product = assigns(:dbms_product)
    vue_model = assigns(:vue_model)
    assert_nil dbms_product.id
    assert vue_model
    assert_tag tag: 'p', attributes: { id: 'mx-dbms-product' }
    assert_tag tag: 'p', attributes: { id: 'mx-data-types' }
    assert_tag tag: 'div', attributes: { id: 'admin-menu' }
    assert_tag tag: 'a', attributes: { href: mx_dbms_products_path }
  end

  def test_new_by_not_admin
    by_not_admin
    delete :new
    assert_response 403
  end

  def test_new_by_anonymous
    delete :new
    assert_response 302
    assert_redirected_to '/login?back_url=http%3A%2F%2Ftest.host%2Fmx%2Fdbms_products%2Fnew'
  end

  def test_create_by_admin_with_valid_params
    by_admin
    assert_difference 'MxDbmsProduct.count', 1 do
      post :create, mx_dbms_product: valid_create_params
    end
    assert_response 302
    assert_redirected_to mx_dbms_product_path(6)
    assert_saved_dbms_product(6, valid_create_params)
  end

  def test_create_should_save_data_types_by_admin_with_valid_params
    by_admin
    assert_difference 'MxDataType.count', 3 do
      post :create, mx_dbms_product: valid_create_params
    end
    assert_response 302
    assert_redirected_to mx_dbms_product_path(6)
  end

  def test_create_by_not_admin
    by_not_admin

    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: valid_create_params
    end
    assert_response 403
  end

  def test_create_by_anonymous
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: valid_create_params
    end
    assert_response 302
    assert_redirected_to '/login?back_url=http%3A%2F%2Ftest.host%2Fmx%2Fdbms_products'
  end

  def test_create_with_empty_name
    by_admin
    params = valid_create_params.tap { |p| p[:name] = '' }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal "can't be blank", assigns(:vue_model).errors[:name].first
  end

  def test_create_without_name
    by_admin
    params = valid_create_params.tap { |p| p.delete(:name) }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal "can't be blank", assigns(:vue_model).errors[:name].first
  end

  def test_create_with_too_long_name
    by_admin
    params = valid_create_params.tap { |p| p[:name] = 'a' * 201 }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_match(/is too long/, assigns(:vue_model).errors[:name].first)
  end

  def test_create_with_already_existed_name
    by_admin
    params = valid_create_params.tap { |p| p[:name] = 'MySQL' }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal 'has already been taken', assigns(:vue_model).errors[:name].first
  end

  def test_create_with_just_long_name
    by_admin
    params = valid_create_params.tap { |p| p[:name] = 'a' * 200 }
    assert_difference 'MxDbmsProduct.count', 1 do
      post :create, mx_dbms_product: params
    end
    assert_response 302
    assert_redirected_to mx_dbms_product_path(6)
    assert_saved_dbms_product(6, params)
  end

  def test_create_with_empty_type
    by_admin
    params = valid_create_params.tap { |p| p[:type] = '' }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal "can't be blank", assigns(:vue_model).errors[:type].first
  end

  def test_create_without_type
    by_admin
    params = valid_create_params.tap { |p| p.delete(:type) }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal "can't be blank", assigns(:vue_model).errors[:type].first
  end

  def test_create_with_invalid_type
    by_admin
    params = valid_create_params.tap { |p| p[:type] = 'invalid' }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal 'is not included in the list', assigns(:vue_model).errors[:type].first
  end

  def test_create_without_comment
    by_admin
    params = valid_create_params.tap { |p| p.delete(:comment) }
    assert_difference 'MxDbmsProduct.count', 1 do
      post :create, mx_dbms_product: params
    end
    assert_response 302
    assert_redirected_to mx_dbms_product_path(6)
    assert_saved_dbms_product(6, params)
  end

  def test_create_without_data_types
    by_admin
    params = valid_create_params.tap { |p| p.delete(:data_types) }
    assert_difference 'MxDbmsProduct.count', 1 do
      post :create, mx_dbms_product: params
    end
    assert_response 302
    assert_redirected_to mx_dbms_product_path(6)
    assert_saved_dbms_product(6, params)
  end

  def test_create_without_data_types_should_not_save_data_types
    by_admin
    params = valid_create_params.tap { |p| p.delete(:data_types) }
    assert_no_difference 'MxDataType.count' do
      post :create, mx_dbms_product: params
    end
    assert_response 302
    assert_redirected_to mx_dbms_product_path(6)
  end

  def test_create_with_empty_data_type_name
    by_admin
    params = valid_create_params.tap { |p| p[:data_types]['v-a'][:name] = '' }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal "can't be blank", assigns(:vue_model).errors[:data_type_name].first
  end

  def test_create_without_data_type_name
    by_admin
    params = valid_create_params.tap { |p| p[:data_types]['v-a'].delete(:name) }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal "can't be blank", assigns(:vue_model).errors[:data_type_name].first
  end

  def test_create_with_too_long_data_type_name
    by_admin
    params = valid_create_params.tap { |p| p[:data_types]['v-a'][:name] = 'a' * 201 }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_match(/is too long/, assigns(:vue_model).errors[:data_type_name].first)
  end

  def test_create_with_just_long_type_name
    by_admin
    params = valid_create_params.tap { |p| p[:data_types]['v-a'][:name] = 'a' * 200 }
    assert_difference 'MxDbmsProduct.count', 1 do
      post :create, mx_dbms_product: params
    end
    assert_response 302
    assert_redirected_to mx_dbms_product_path(6)
    assert_saved_dbms_product(6, params)
  end

  def test_create_with_duplicated_type_names
    by_admin
    params = valid_create_params.tap { |p| p[:data_types]['v-a'][:name] = 'bar' }
    assert_no_difference 'MxDbmsProduct.count' do
      post :create, mx_dbms_product: params
    end
    assert_response :success
    assert_template 'new'
    assert_equal 'is duplicated', assigns(:vue_model).errors[:data_type_name].first
  end

  def test_edit_by_admin
    by_admin
    get :edit, id: 1
    assert_response :success
    assert_template 'edit'
    dbms_product = assigns(:dbms_product)
    vue_model = assigns(:vue_model)
    assert_equal 1, dbms_product.id
    assert vue_model
    assert_tag tag: 'p', attributes: { id: 'mx-dbms-product' }
    assert_tag tag: 'p', attributes: { id: 'mx-data-types' }
    assert_tag tag: 'div', attributes: { id: 'admin-menu' }
    assert_tag tag: 'a', attributes: { href: mx_dbms_products_path }
  end

  def test_edit_by_not_admin
    by_not_admin
    delete :edit, id: 1
    assert_response 403
  end

  def test_edit_by_anonymous
    delete :edit, id: 1
    assert_response 302
    assert_redirected_to '/login?back_url=http%3A%2F%2Ftest.host%2Fmx%2Fdbms_products%2F1%2Fedit'
  end

  def test_edit_with_invalid_id
    by_admin
    delete :edit, id: 99
    assert_response 404
  end

  def test_update_by_admin_with_valid_params
    by_admin
    assert_no_difference 'MxDbmsProduct.count' do
      post :update, id: 5, mx_dbms_product: valid_update_params
    end
    assert_response 302
    assert_redirected_to mx_dbms_product_path(5)
    assert_saved_dbms_product(5, valid_update_params)
  end

  def test_update_should_save_data_types_by_admin_with_valid_params
    by_admin
    assert_difference 'MxDataType.count', -2 do
      post :update, id: 5, mx_dbms_product: valid_update_params
    end
    assert_response 302
    assert_redirected_to mx_dbms_product_path(5)
  end

  def test_update_by_not_admin
    by_not_admin

    assert_no_difference 'MxDbmsProduct.count' do
      post :update, id: 5, mx_dbms_product: valid_update_params
    end
    assert_response 403
  end

  def test_update_by_anonymous
    assert_no_difference 'MxDbmsProduct.count' do
      post :update, id: 5, mx_dbms_product: valid_update_params
    end
    assert_response 302
    assert_redirected_to '/login?back_url=http%3A%2F%2Ftest.host%2Fmx%2Fdbms_products%2F5'
  end

  def test_update_with_empty_name
    by_admin
    params = valid_update_params.tap { |p| p[:name] = '' }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_equal "can't be blank", assigns(:vue_model).errors[:name].first
  end

  def test_update_without_name
    by_admin
    params = valid_update_params.tap { |p| p.delete(:name) }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_equal "can't be blank", assigns(:vue_model).errors[:name].first
  end

  def test_update_with_too_long_name
    by_admin
    params = valid_update_params.tap { |p| p[:name] = 'a' * 201 }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_match(/is too long/, assigns(:vue_model).errors[:name].first)
  end

  def test_update_with_already_taken_name
    by_admin
    params = valid_update_params.tap { |p| p[:name] = 'MySQL' }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_equal 'has already been taken', assigns(:vue_model).errors[:name].first
  end

  def test_update_with_just_long_name
    by_admin
    params = valid_update_params.tap { |p| p[:name] = 'a' * 200 }
    put :update, id: 5, mx_dbms_product: params
    assert_response 302
    assert_redirected_to mx_dbms_product_path(5)
    assert_saved_dbms_product(5, params)
  end

  def test_update_with_empty_type
    by_admin
    params = valid_update_params.tap { |p| p[:type] = '' }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_equal "can't be blank", assigns(:vue_model).errors[:type].first
  end

  def test_update_without_type
    by_admin
    params = valid_update_params.tap { |p| p.delete(:type) }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_equal "can't be blank", assigns(:vue_model).errors[:type].first
  end

  def test_update_with_invalid_type
    by_admin
    params = valid_update_params.tap { |p| p[:type] = 'invalid' }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_equal 'is not included in the list', assigns(:vue_model).errors[:type].first
  end

  def test_update_without_comment
    by_admin
    params = valid_update_params.tap { |p| p.delete(:comment) }
    put :update, id: 5, mx_dbms_product: params
    assert_response 302
    assert_redirected_to mx_dbms_product_path(5)
    assert_saved_dbms_product(5, params)
  end

  def test_update_without_data_types
    by_admin
    params = valid_update_params.tap { |p| p.delete(:data_types) }
    put :update, id: 5, mx_dbms_product: params
    assert_response 302
    assert_redirected_to mx_dbms_product_path(5)
    assert_saved_dbms_product(5, params)
  end

  def test_update_without_data_types_should_not_save_data_types
    by_admin
    params = valid_update_params.tap { |p| p.delete(:data_types) }
    put :update, id: 5, mx_dbms_product: params
    assert_response 302
    assert_redirected_to mx_dbms_product_path(5)
  end

  def test_update_with_empty_data_type_name
    by_admin
    params = valid_update_params.tap { |p| p[:data_types]['v-c'][:name] = '' }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_equal "can't be blank", assigns(:vue_model).errors[:data_type_name].first
  end

  def test_update_without_data_type_name
    by_admin
    params = valid_update_params.tap { |p| p[:data_types]['v-c'].delete(:name) }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_equal "can't be blank", assigns(:vue_model).errors[:data_type_name].first
  end

  def test_update_with_too_long_data_type_name
    by_admin
    params = valid_update_params.tap { |p| p[:data_types]['v-c'][:name] = 'a' * 201 }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_match(/is too long/, assigns(:vue_model).errors[:data_type_name].first)
  end

  def test_update_with_just_long_type_name
    by_admin
    params = valid_update_params.tap { |p| p[:data_types]['v-c'][:name] = 'a' * 200 }
    put :update, id: 5, mx_dbms_product: params
    assert_response 302
    assert_redirected_to mx_dbms_product_path(5)
    assert_saved_dbms_product(5, params)
  end

  def test_update_with_duplicated_type_names
    by_admin
    params = valid_update_params.tap { |p| p[:data_types]['v-c'][:name] = 'TEXT' }
    put :update, id: 5, mx_dbms_product: params
    assert_response :success
    assert_template 'edit'
    assert_equal 'is duplicated', assigns(:vue_model).errors[:data_type_name].first
  end

  private

  def valid_create_params
    {
      name: 'test',
      type: 'postgresql',
      comment: "foo\nbar\nbaz",
      data_types: {
        'v-a' => {
          id: 'v-a',
          name: 'foo',
          position: '0'
        },
        'v-b' => {
          id: 'v-a',
          name: 'bar',
          sizable: 'true',
          scalable: 'true',
          use_by_default: 'true',
          position: '1'
        },
        'v-c' => {
          id: 'v-c',
          name: 'baz',
          scalable: 'true',
          position: '2'
        }
      }
    }
  end

  def valid_update_params
    {
      name: 'test',
      type: 'postgresql',
      comment: "foo\nbar\nbaz",
      data_types: {
        '86' => {
          id: '86',
          name: 'TEXT',
          use_by_default: 'true',
          position: '0'
        },
        '87' => {
          id: '87',
          name: 'NUMBER',
          sizable: 'true',
          scalable: 'true',
          use_by_default: 'true',
          position: '1'
        },
        'v-c' => {
          id: 'v-c',
          name: 'BLOB',
          position: '2'
        }
      }
    }
  end

  def assert_saved_dbms_product(id, params)
    dbms_product = MxDbmsProduct.find(id)
    assert_equal params[:name], dbms_product.name
    assert_equal params[:type], dbms_product.type
    assert_equal params[:comment], dbms_product.comment
    if params[:data_types]
      assert_equal params[:data_types].size, dbms_product.data_types.size
      params[:data_types].each do |data_type_id, data_type_param|
        data_type = dbms_product.data_types.where(name: data_type_param[:name]).first
        assert data_type
        assert_equal !!data_type_param[:sizable], data_type.sizable
        assert_equal !!data_type_param[:scalable], data_type.scalable
        assert_equal !!data_type_param[:use_by_default], data_type.use_by_default
      end
    else
      assert_equal 0, dbms_product.data_types.size
    end
  end
end
