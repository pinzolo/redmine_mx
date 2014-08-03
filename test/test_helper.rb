require 'coveralls'
require 'simplecov'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter do |source_file|
    !source_file.filename.include?('plugins/redmine_mx') || !source_file.filename.end_with?('.rb')
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
