class MxIssueRelation < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :mx_issue_relatable, polymorphic: true
end
