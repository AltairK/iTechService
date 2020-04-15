class CitiesController < ApplicationController
  respond_to :html

  def index
    authorize City
    @cities = policy_scope(City)
  end

  def new
    @city = authorize(City.new)
    render 'form'
  end

  def create
    @city = authorize(City.new(params[:city]))

    if @city.save
      redirect_to cities_path, notice: 'Город создан'
    else
      render 'form'
    end
  end

  def edit
    @city = find_record(City)
    render 'form'
  end

  def update
    @city = find_record(City)

    if @city.update(params[:city])
      redirect_to cities_path, notice: 'Город изменён'
    else
      render 'form'
    end
  end

  def destroy
    @city = find_record(City)
    @city.destroy
    redirect_to cities_path, notice: 'Город удалён'
  end
end
