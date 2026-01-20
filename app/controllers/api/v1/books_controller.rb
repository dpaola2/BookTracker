class Api::V1::BooksController < ApplicationController
  before_action :valid_api_user?

  def index
    # render json: params.to_json
    render json: {
      user: @current_user.email,
      books: @current_user.books.all,
      book_count: @current_user.books.count
  }
  end

  def show
    book = @current_user.books.find_by(id: params[:id])
    if book
      render json: {
        book: {
          id: book.id,
          title: book.title,
          author: book.author,
          isbn: book.isbn,
          image_url: book_image_url(book),
          comments: book.comments.to_s
        }
      }
    else
      render json: { error: "Book not found" }, status: 404
    end
  end

  private

  def book_image_url(book)
    if book.image.attached?
      rails_blob_url(book.image, only_path: false)
    elsif book.isbn_search_results.first&.image_url.present?
      book.isbn_search_results.first.image_url
    end
  end

  def valid_api_user?
    
    if 
      token = params[:api_key]
      user_id = params[:user_id]

      user = User.find_by(api_key: token, id: user_id)

      if user
        @current_user = user
        return true
      else
        render json: { error: "Invalid API Key: #{ params[:api_key] }" }, status: 401
      end
    else
      render json: { error: 'API Key and UserID Required' }, status: 401
    end
  end
end