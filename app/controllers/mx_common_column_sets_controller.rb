class MxCommonColumnSetsController < ApplicationController
  include MxProjectFixation
  unloadable

  before_filter :find_database
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

  def find_database
    @database = MxDatabase.find(params[:database_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_common_column_set
    @common_column_set = MxCommonColumnSet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
