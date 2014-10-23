class MxTableVersion < ActiveRecord::Base
  include MxIssueRelatable
  unloadable
end
