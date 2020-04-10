class PurchasesController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    authorize Purchase
    @purchases = policy_scope(Purchase).search(params).page(params[:page])

    if params.has_key?(:sort) && params.has_key?(:direction)
      @purchases = @purchases.order("purchases.#{sort_column} #{sort_direction}")
    else
      @purchases = @purchases.order(date: :desc)
    end

    @purchases = @purchases.page(params[:page])

    respond_to do |format|
      format.html
      format.js { render 'shared/index' }
      format.json { render json: @purchases }
    end
  end

  def show
    @purchase = find_record Purchase
    respond_to do |format|
      format.html
      format.json { render json: @purchase }
    end
  end

  def new
    @purchase = authorize Purchase.new
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @purchase }
    end
  end

  def edit
    @purchase = find_record Purchase
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @purchase }
    end
  end

  def create
    @purchase = authorize Purchase.new(params[:purchase])
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
    @purchase = find_record Purchase
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
    @purchase = find_record Purchase
    @purchase.set_deleted
    respond_to do |format|
      format.html { redirect_to purchases_url }
      format.json { head :no_content }
    end
  end

  def post
    @purchase = find_record Purchase
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
    @purchase = find_record Purchase
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
    @purchase = find_record Purchase
    respond_to do |format|
      format.pdf do
        pdf = ProductTagsPdf.new @purchase, view_context, params
        send_data pdf.render, filename: 'product_tags', type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def revaluate_products
    purchase = find_record Purchase
    revaluation_act = purchase.build_revaluation_act params[:product_ids]
    respond_to do |format|
      if revaluation_act.save
        format.html { redirect_to edit_revaluation_act_path(revaluation_act) }
      else
        format.html { redirect_to purchase, error: revaluation_act.errors.full_messages.join('. ') }
      end
    end
  end

  def move_items
    purchase = find_record Purchase
    movement_act = purchase.build_movement_act params[:item_ids]
    respond_to do |format|
      if movement_act.save
        format.html { redirect_to edit_movement_act_path(movement_act) }
      else
        format.html { redirect_to purchase, error: movement_act.errors.full_messages.join('. ') }
      end
    end
  end

  private

  def sort_column
    Purchase.column_names.include?(params[:sort]) ? params[:sort] : ''
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : ''
  end
end
