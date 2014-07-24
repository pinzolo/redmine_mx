class MxCommonColumnSetsController < ApplicationController
  include MxProjectFixation
  unloadable

  before_filter :find_table_list
  before_filter :find_common_column_set, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def find_table_list
    @table_list = MxTableList.find(params[:table_list_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_common_column_set
    @common_column_set = MxCommonColumnSet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
