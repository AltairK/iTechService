class LocationsController < ApplicationController
  load_and_authorize_resource

  def index
    @locations = Location.all

    respond_to do |format|
      format.html
      format.json { render json: @locations }
    end
  end

  def new
    @location = Location.new

    respond_to do |format|
      format.html { render 'form'}
      format.json { render json: @location }
    end
  end

  def edit
    @location = Location.find(params[:id])
    respond_to do |format|
      format.html { render 'form'}
    end
  end

  def create
    @location = Location.new(params[:location])

    respond_to do |format|
      if @location.save
        format.html { redirect_to locations_path, notice: t('locations.created') }
        format.json { render json: @location, status: :created, location: @location }
      else
        format.html { render 'form'}
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @location = Location.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[:location])
        format.html { redirect_to locations_path, notice: t('locations.updated') }
        format.json { head :no_content }
      else
        format.html { render 'form'}
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to locations_url }
      format.json { head :no_content }
    end
  end
end
