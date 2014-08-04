class MxDatabasesController < ApplicationController
  include MxProjectFixation
  unloadable

  def index
    @databases = MxDatabase.where(project_id: @project.id).order(:identifier)
  end

  def show
  end

  def new
    @vue_model = MxVm::Database.new
  end

  def create
    @vue_model = MxVm::Database.new(params[:mx_vm_database])
    if @vue_model.valid?
      @database = MxDatabase.new(project_id: @project.id)
      @database.save_with(@vue_model)
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_mx_database_path(@project, @database)
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
end
