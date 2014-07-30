class MxDbmsProductsController < ApplicationController
  unloadable

  before_filter :require_admin, only: [:new, :create, :edit, :update]
  before_filter :find_dbms_product, only: [:show, :edit, :update, :destroy]

  def index
    @dbms_products = MxDbmsProduct.order(:name).to_a
    render layout: User.current.admin? ? 'admin' : 'base'
  end

  def show
    render layout: User.current.admin? ? 'admin' : 'base'
  end

  def new
    @dbms_product = MxDbmsProduct.new
    @vue_model = MxDbmsProductVueModel.new(@dbms_product)
    render layout: 'admin'
  end

  def create
  end

  def edit
    @vue_model = MxDbmsProductVueModel.new(@dbms_product)
    render layout: 'admin'
  end

  def update
  end

  def destroy
    @dbms_product.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: :index
  end

  private

  def find_dbms_product
    @dbms_product = MxDbmsProduct.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
