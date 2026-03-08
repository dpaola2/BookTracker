class IsbnSearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_book

  def create
    searcher = IsbnSearcher.new(book: @book)
    flash[:alert] = "ISBNdb API error" unless searcher.search

    redirect_to book_url(@book)
  end

  private

  def find_book
    @book = current_user.books.find(params[:book_id])
  end
end
