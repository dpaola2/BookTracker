class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_isbn_search_result

  def create
    if @isbn_search_result.book.update(
      isbn: @isbn_search_result.isbn13,
      title: @isbn_search_result.title,
      author: @isbn_search_result.authors
    )
      flash[:notice] = "Book was successfully assigned."
    else
      flash[:alert] = "There was a problem assigning the book."
    end
    redirect_to book_path(@isbn_search_result.book)
  end

  private

  def find_isbn_search_result
    @isbn_search_result = IsbnSearchResult.find(params[:isbn_search_id])
  end
end
