class MxDatabasesController < ApplicationController
  include MxProjectFixation
  unloadable

  before_filter :find_database, only: [:show, :edit, :update, :destroy]
  accept_api_auth :index

  def index
    @databases = MxDatabase.where(project_id: @project.id).includes(:dbms_product, :mx_comment).order(:identifier)
    respond_to do |format|
      format.html
      format.json { render json: @databases.as_json(root: false, except: [:lock_version], methods: [:comment]) }
      format.xml { render xml: @databases.to_xml(except: [:lock_version]) }
    end
  end

  def show
    redirect_to project_mx_database_tables_path(@project, @database)
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
      redirect_to project_mx_databases_path(@project)
    else
      render action: :new
    end
  end

  def edit
    @vue_model = MxVm::Database.new(@database)
  end

  def update
    @vue_model = MxVm::Database.new(params[:mx_vm_database].merge(id: @database.id))
    if @vue_model.valid?
      @database.save_with(@vue_model)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_mx_databases_path(@project)
    else
      render action: :edit
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:error] = l(:notice_locking_conflict)
    render action: :edit
  end

  def destroy
    @database.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to project_mx_databases_path(@project)
  end

  def find_database
    @database = MxDatabase.find_database(@project, params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
