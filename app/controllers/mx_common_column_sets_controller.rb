class MxCommonColumnSetsController < ApplicationController
  include MxProjectFixation
  include MxDatabaseFixation
  unloadable

  before_filter :find_database
  before_filter :find_common_column_set, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
    @common_column_set = MxCommonColumnSet.new
    @vue_model = MxVm::CommonColumnSet.new
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

  def find_common_column_set
    @common_column_set = MxCommonColumnSet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
