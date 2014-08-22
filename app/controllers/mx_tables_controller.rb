class MxTablesController < ApplicationController
  include MxProjectFixation
  include MxDatabaseFixation
  unloadable

  before_filter :find_table, only: [:show, :edit, :update, :destroy]

  def index
    @tables = MxTable.where(database_id: @database).order(:physical_name).includes(:table_columns, :mx_comment)
  end

  def show
  end

  def new
    @table = MxTable.new
    @vue_model = MxVm::Table.new(@table, @database)
  end

  def create
    @table = @database.tables.build
    @vue_model = MxVm::Table.new(params[:mx_table], @database)
    if @vue_model.valid?
      @table.project_id = @project.id
      @table.created_user_id = User.current.id
      @table.updated_user_id = User.current.id
      @table.save_with!(@vue_model)
      flash[:notice] = l(:notice_successful_create)
      redirect_to(params[:continue] ? new_project_mx_database_table_path(@project, @database) : project_mx_database_table_path(@project, @database, @table))
    else
      render action: :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def find_table
    @table = MxTable.find_table(@database, params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
