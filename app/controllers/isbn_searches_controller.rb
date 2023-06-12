class IsbnSearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_book

  def create
    @book.isbn_search_results.destroy_all

    client = ISBNdb::ApiClient.new(api_key: ENV['ISBNDB_API_KEY'])
    isbn_results = client.book.batch("#{ @book['title'] } #{ @book['author'] }")[:books]
    isbn_results.map do |isbn_result|
      @book.isbn_search_results.create!(
        isbn13: isbn_result[:isbn13],
        isbn10: isbn_result[:isbn10],
        title: isbn_result[:title],
        authors: isbn_result[:authors].join(","),
        image_url: isbn_result[:image]
      )
    end

    redirect_to book_url(@book)
  end

  private

  def find_book
    @book = current_user.books.find(params[:book_id])
  end
end
