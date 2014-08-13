class MxCommonColumnSetsController < ApplicationController
  include MxProjectFixation
  include MxDatabaseFixation
  unloadable

  before_filter :find_common_column_set, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
    @common_column_set = MxCommonColumnSet.new
    @vue_model = MxVm::CommonColumnSet.new(@common_column_set, @database)
  end

  def create
    @common_column_set = @database.common_column_sets.build
    @vue_model = MxVm::CommonColumnSet.new(params[:mx_common_column_set], @database)
    if @vue_model.valid?
      @common_column_set.save_with!(@vue_model)
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_mx_database_common_column_set_path(@project, @database, @common_column_set)
    else
      render action: :new
    end
  end

  def edit
    @vue_model = MxVm::CommonColumnSet.new(@common_column_set, @database)
  end

  def update
    @vue_model = MxVm::CommonColumnSet.new(params[:mx_common_column_set], @database)
    if @vue_model.valid?
      @common_column_set.save_with!(@vue_model)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_mx_database_common_column_set_path(@project, @database, @common_column_set)
    else
      render action: :edit
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:error] = l(:notice_locking_conflict)
    render action: :edit
  end

  def destroy
    @common_column_set.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: :index
  end

  private

  def find_common_column_set
    @common_column_set = MxCommonColumnSet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
