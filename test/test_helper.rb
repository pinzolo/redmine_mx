# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

def by_admin
  @request.session[:user_id] = 1
end

def by_not_admin
  @request.session[:user_id] = 2
end
