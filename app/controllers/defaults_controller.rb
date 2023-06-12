class DefaultsController < ApplicationController
  def create
    @shelf = current_user.shelves.find(params[:shelf_id])

    if current_user.update(shelf_id: @shelf.id)
      redirect_to shelf_url(@shelf), notice: "Default shelf was successfully updated."
    else
      redirect_to shelf_url(@shelf), alert: "Default shelf was not successfully updated."
    end
  end
end
