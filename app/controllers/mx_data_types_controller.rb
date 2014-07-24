class MxDataTypesController < ApplicationController
  unloadable

  before_filter :find_database
  before_filter :find_data_type, only: [:show, :edit, :update, :destroy]

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

  def find_data_type
    @data_type = MxDataType.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
