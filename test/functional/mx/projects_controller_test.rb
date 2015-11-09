require File.expand_path('../../../test_helper', __FILE__)

module Mx
  class ProjectsControllerTest < ActionController::TestCase
    tests ProjectsController
    fixtures :projects, :users, :roles, :members, :member_roles

    def setup
      User.current = nil
      enable_mx!
      setup_mx_permissions!
      @project = Project.find('ecookbook')
    end

    def test_show_with_mx_by_manager
      by_manager

      get :show, id: 'ecookbook'
      assert_select "div#main-menu a[href='#{project_mx_path(@project)}']"
    end

    def test_show_with_mx_by_viewer
      by_viewer

      get :show, id: 'ecookbook'
      assert_select "div#main-menu a[href='#{project_mx_path(@project)}']"
    end

    def test_show_with_mx_by_not_member
      by_not_member

      get :show, id: 'ecookbook'
      assert_select "div#main-menu a[href='#{project_mx_path(@project)}']", false
    end
  end
end

