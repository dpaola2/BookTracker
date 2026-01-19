class BookSearchesController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = current_user.books.ransack(params[:q])
    @pagy, @books = pagy(@q.result(distinct: true))
  end
end
