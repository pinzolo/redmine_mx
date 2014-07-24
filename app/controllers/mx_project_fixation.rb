module MxProjectFixation
  extend ActiveSupport::Concern

  included do
    menu_item :mx
    before_filter :find_project, :authorize
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
