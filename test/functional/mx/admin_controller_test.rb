require File.expand_path('../../../test_helper', __FILE__)

module Mx
  class AdminControllerTest < ActionController::TestCase
    tests AdminController
    fixtures :users

    def setup
      by_admin
    end

    def test_index_with_mx
      get :index
      assert_tag tag: 'a', attributes: { href: mx_dbms_products_path }
    end
  end
end
