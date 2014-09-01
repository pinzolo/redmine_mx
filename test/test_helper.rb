require 'coveralls'
require 'simplecov'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter do |source_file|
    not_plugin_file = !source_file.filename.include?('plugins/redmine_mx')
    not_ruby_file = !source_file.filename.end_with?('.rb')
    test_file = source_file.filename.include?('plugins/redmine_mx/test/')
    not_plugin_file || not_ruby_file || test_file
  end
end

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

def by_admin
  @request.session[:user_id] = 1
end

def by_not_admin
  @request.session[:user_id] = 2
end

def by_manager
  @request.session[:user_id] = 2
end

def by_viewer
  @request.session[:user_id] = 3
end

def by_not_member
  @request.session[:user_id] = 4
end

def enable_mx!(project=nil)
  prj = project || Project.find('ecookbook')
  prj.enable_module!('mx')
end

def setup_mx_permissions!
  Role.find(1).add_permission!(:view_mx_tables, :manage_mx_tables)
  Role.find(2).add_permission!(:view_mx_tables)
end

def assert_conflict_flash
  assert_tag tag: 'div', attributes: { id: 'flash_error' }, content: I18n.t(:notice_locking_conflict)
end

def assert_have_error(attribute, error, model = :vue_model)
  if error.is_a?(Regexp)
    assert_match error, assigns(model).errors[attribute].first
  else
    assert_equal error, assigns(model).errors[attribute].first
  end
end
