class MxTablesController < ApplicationController
  include MxProjectFixation
  include MxDatabaseFixation
  unloadable

  before_filter :find_table, only: [:show, :edit, :update, :destroy]

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

  def find_table
    @table = MxTable.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
