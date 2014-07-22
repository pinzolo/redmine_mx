module MxIssueRelatable
  extend ActiveSupport::Concern

  included do
    has_many :issue_relations, as: :mx_issue_relatable, class_name: 'MxIssueRelation'
    has_many :issues, through: :issue_relations
  end

  def add_issue(issue)
    iss = find_issue(issue)
    self.issues << tag if iss && !self.issues.include?(iss)
  end

  def remove_issue(issue)
    iss = find_issue(issue)
    self.issues.delete(iss) if iss && self.tags.include?(iss)
  end

  private

  def find_issue(issue)
    issue.is_a?(Issue) ? issue : Issue.where(id: issue).first
  end
end

