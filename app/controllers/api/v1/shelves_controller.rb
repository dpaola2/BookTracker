class Api::V1::ShelvesController < ApplicationController
  before_action :valid_api_user?

  def index
    render json: {
      user: @current_user.email,
      shelves: @current_user.shelves.map { |s|
        {
          id: s.id,
          name: s.name,
          book_count: s.books.count
        }
      }
    }
  end

  def show
    shelf = @current_user.shelves.find_by(id: params[:id])

    if shelf
      render json: {
        user: @current_user.email,
        shelf: {
          id: shelf.id,
          name: shelf.name,
          book_count: shelf.books.count,
          books: shelf.books.map { |b|
            {
              id: b.id,
              title: b.title,
              author: b.author,
              isbn: b.isbn,
              image_url: book_image_url(b)
            }
          }
        }
      }
    else
      render json: { error: "Shelf not found" }, status: 404
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
    token = params[:api_key]
    user_id = params[:user_id]

    if token.present? && user_id.present?
      user = User.find_by(api_key: token, id: user_id)

      if user
        @current_user = user
        return true
      else
        render json: { error: "Invalid API Key" }, status: 401
      end
    else
      render json: { error: 'API Key and UserID Required' }, status: 401
    end
  end
end
