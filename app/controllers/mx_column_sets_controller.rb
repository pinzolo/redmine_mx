class MxColumnSetsController < ApplicationController
  include MxProjectFixation
  include MxDatabaseFixation
  unloadable

  before_filter :find_column_set, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
    @column_set = MxColumnSet.new
    @vue_model = MxVm::ColumnSet.new(@column_set, @database)
  end

  def create
    @column_set = @database.column_sets.build
    @vue_model = MxVm::ColumnSet.new(params[:mx_column_set], @database)
    if @vue_model.valid?
      @column_set.save_with!(@vue_model)
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_mx_database_column_set_path(@project, @database, @column_set)
    else
      render action: :new
    end
  end

  def edit
    @vue_model = MxVm::ColumnSet.new(@column_set, @database)
  end

  def update
    @vue_model = MxVm::ColumnSet.new(params[:mx_column_set], @database)
    if @vue_model.valid?
      @column_set.save_with!(@vue_model)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_mx_database_column_set_path(@project, @database, @column_set)
    else
      render action: :edit
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:error] = l(:notice_locking_conflict)
    render action: :edit
  end

  def destroy
    @column_set.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: :index
  end

  private

  def find_column_set
    @column_set = MxColumnSet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
