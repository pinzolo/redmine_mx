class MxDbmsProductsController < ApplicationController
  unloadable

  before_filter :require_login
  before_filter :require_admin, only: [:new, :create, :edit, :update, :destroy]
  before_filter :find_dbms_product, only: [:show, :edit, :update, :destroy]
  accept_api_auth :index, :show

  def index
    @dbms_products = MxDbmsProduct.includes(:mx_comment).order(:name)
    render_dbms_products(@dbms_products)
  end

  def show
    render_dbms_products(@dbms_product)
  end

  def new
    @dbms_product = MxDbmsProduct.new
    @vue_model = MxVm::DbmsProduct.new(@dbms_product)
    render layout: 'admin'
  end

  def create
    @vue_model = MxVm::DbmsProduct.new(params[:mx_dbms_product])
    if @vue_model.valid?
      @dbms_product = @vue_model.type.constantize.new
      @dbms_product.save_with!(@vue_model)
      flash[:notice] = l(:notice_successful_create)
      redirect_to mx_dbms_product_path(@dbms_product)
    else
      @dbms_product = MxDbmsProduct.new
      render action: :new, layout: 'admin'
    end
  end

  def edit
    @vue_model = MxVm::DbmsProduct.new(@dbms_product)
    render layout: 'admin'
  end

  def update
    @vue_model = MxVm::DbmsProduct.new(params[:mx_dbms_product].merge(id: @dbms_product.id))
    if @vue_model.valid?
      @dbms_product.save_with!(@vue_model)
      flash[:notice] = l(:notice_successful_update)
      redirect_to mx_dbms_product_path(@dbms_product)
    else
      render action: :edit, layout: 'admin'
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:error] = l(:notice_locking_conflict)
    render action: :edit, layout: 'admin'
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

  def render_dbms_products(value)
    respond_to do |format|
      format.html { render layout: User.current.admin? ? 'admin' : 'base' }
      serialize_options = {
        except: [:lock_version],
        methods: [:comment, :type],
        include: {
          data_types: {
            except: [:dbms_product_id]
          }
        }
      }
      format.json { render json: value.as_json(serialize_options.merge(root: false)) }
      format.xml { render xml: value.to_xml(serialize_options) }
    end
  end
end
