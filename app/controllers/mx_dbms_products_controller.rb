class MxDbmsProductsController < ApplicationController
  unloadable
  layout 'admin'

  before_filter :require_admin
  before_filter :find_dbms_product, only: [:show, :edit, :update, :destroy]

  def index
    @dbms_products = MxDbmsProduct.order(:name).to_a
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

  def find_dbms_product
    @dbms_product = MxDbmsProduct.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
