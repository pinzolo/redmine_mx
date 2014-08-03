require File.expand_path('../../../test_helper', __FILE__)

module Mx
  class ProjectsControllerTest < ActionController::TestCase
    tests ProjectsController
    fixtures :projects, :users, :roles, :members, :member_roles

    def setup
      by_admin
    end

    def test_show_with_mx
      project = Project.find('ecookbook')
      project.enable_module!('mx')
      get :show, id: 'ecookbook'
      assert_tag tag: 'a',
                 attributes: { href: project_mx_path(project) },
                 ancestor: {
                   tag: 'div', attributes: { id: 'main-menu' }
                 }
    end
  end
end

