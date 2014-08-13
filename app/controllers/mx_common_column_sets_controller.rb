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
    @vue_model = MxVm::CommonColumnSet.new
    set_data_types_to_vue_model
  end

  def create
    @common_column_set = MxCommonColumnSet.new(database_id: @database.id)
    @vue_model = MxVm::CommonColumnSet.new(params[:mx_common_column_set])
    if @vue_model.valid?
      @common_column_set.save_with!(@vue_model)
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_mx_database_common_column_set_path(@project, @database, @common_column_set)
    else
      set_data_types_to_vue_model
      render action: :new
    end
  end

  def edit
    @vue_model = MxVm::CommonColumnSet.new(@common_column_set)
    set_data_types_to_vue_model
  end

  def update
    @vue_model = MxVm::CommonColumnSet.new(params[:mx_common_column_set])
    if @vue_model.valid?
      @common_column_set.save_with!(@vue_model)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_mx_database_common_column_set_path(@project, @database, @common_column_set)
    else
      set_data_types_to_vue_model
      render action: :edit
    end
  rescue ActiveRecord::StaleObjectError
    set_data_types_to_vue_model
    flash.now[:error] = l(:notice_locking_conflict)
    render action: :edit
  end

  def destroy

  end

  private

  def find_common_column_set
    @common_column_set = MxCommonColumnSet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def set_data_types_to_vue_model
    @vue_model.data_types = @database.dbms_product.data_types.map { |data_type| MxVm::DataType.new(data_type) }
  end
end
