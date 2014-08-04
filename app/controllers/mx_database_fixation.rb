module MxDatabaseFixation
  extend ActiveSupport::Concern

  included do
    before_filter :find_database
  end

  private

  def find_database
    @database = MxDatabase.find_database(@project, params[:database_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end

