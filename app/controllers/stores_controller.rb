class StoresController < ApplicationController
  def index
    authorize Store
    @stores = policy_scope(Store).search(params)
    respond_to do |format|
      format.html
      format.js { render 'shared/index' }
    end
  end

  def show
    @store = find_record Store
    @product_groups = ProductGroup.roots.search(params.merge(store_kind: @store.kind)).ordered
    @products = @store.products
                  .includes(:product_group, :product_category, :prices, :batches, :items, :store_items)
                  .search(params)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @store = authorize Store.new
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @store }
    end
  end

  def edit
    @store = find_record Store
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @store }
    end
  end

  def create
    @store = authorize Store.new(params[:store])
    respond_to do |format|
      if @store.save
        format.html { redirect_to stores_path, notice: t('stores.created') }
        format.json { render json: @store, status: :created, location: @store }
      else
        format.html { render 'form' }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @store = find_record Store
    respond_to do |format|
      if @store.update_attributes(params[:store])
        format.html { redirect_to stores_path, notice: t('stores.updated') }
        format.json { head :no_content }
      else
        format.html { render 'form' }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @store = find_record Store
    @store.destroy

    respond_to do |format|
      format.html { redirect_to stores_url }
      format.json { head :no_content }
    end
  end

  def product_details
    store = find_record Store
    @product = Product.find params[:product_id]
    @store_items = @product.store_items.in_store store
    respond_to do |format|
      format.js
    end
  end
end
