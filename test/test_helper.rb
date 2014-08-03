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
