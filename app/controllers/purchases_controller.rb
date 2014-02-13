class PurchasesController < ApplicationController
  authorize_resource

  def index
    @purchases = Purchase.search(params).page(params[:page])
    respond_to do |format|
      format.html
      format.js { render 'shared/index' }
      format.json { render json: @purchases }
    end
  end

  def show
    @purchase = Purchase.find params[:id]
    respond_to do |format|
      format.html
      format.json { render json: @purchase }
    end
  end

  def new
    @purchase = Purchase.new
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @purchase }
    end
  end

  def edit
    @purchase = Purchase.find params[:id]
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @purchase }
    end
  end

  def create
    @purchase = Purchase.new params[:purchase]
    respond_to do |format|
      if @purchase.save
        format.html { redirect_to @purchase, notice: t('purchases.created') }
        format.json { render json: @purchase, status: :created, location: @purchase }
      else
        format.html { render 'form' }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @purchase = Purchase.find params[:id]
    respond_to do |format|
      if @purchase.update_attributes(params[:purchase])
        format.html { redirect_to @purchase, notice: t('purchases.updated') }
        format.json { head :no_content }
      else
        format.html { render 'form' }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @purchase = Purchase.find params[:id]
    @purchase.set_deleted
    respond_to do |format|
      format.html { redirect_to purchases_url }
      format.json { head :no_content }
    end
  end

  def post
    @purchase = Purchase.find params[:id]
    respond_to do |format|
      if @purchase.post
        format.html { redirect_to @purchase, notice: t('purchases.posted') }
      else
        flash.alert = @purchase.errors.full_messages
        format.html { redirect_to @purchase, error: t('purchases.not_posted') }
      end
    end
  end

  def unpost
    @purchase = Purchase.find params[:id]
    respond_to do |format|
      if @purchase.unpost
        format.html { redirect_to @purchase, notice: t('purchases.unposted') }
      else
        flash.alert = @purchase.errors.full_messages
        format.html { redirect_to @purchase, error: t('purchases.not_unposted') }
      end
    end
  end

  def print_barcodes
    @purchase = Purchase.find params[:id]
    respond_to do |format|
      format.pdf do
        pdf = ProductTagsPdf.new @purchase, view_context, params
        send_data pdf.render, filename: 'product_tags', type: 'application/pdf', disposition: 'inline'
      end
    end
  end

end
