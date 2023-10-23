class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_isbn_search_result

  def create
    result = IsbnAssigner.new(book: @isbn_search_result.book, isbn_search_result: @isbn_search_result).assign

    if result
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
