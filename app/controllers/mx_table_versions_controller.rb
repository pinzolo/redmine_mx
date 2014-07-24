class MxTableVersionsController < ApplicationController
  include MxProjectFixation
  include MxTableListFixation
  unloadable

  before_filter :find_table

  def index
  end

  def show
  end

  private

  def find_table
    @table = MxTable.find(params[:table_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
