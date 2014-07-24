module MxTableListFixation
  extend ActiveSupport::Concern

  included do
    before_filter :find_table_list
  end

  private

  def find_table_list
    @table_list = MxTableList.find(params[:table_list_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end

