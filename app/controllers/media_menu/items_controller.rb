module MediaMenu
  class ItemsController < BaseController
    respond_to :js

    def index
      run Item::Index
      render 'index', locals: {content: cell(Item::Cell::Row, collection: @model).call}
    end

    def show
      model = Item.find params[:id]
      render 'show', locals: {content: cell(Item::Cell::Details, model).call}
    end
  end
end