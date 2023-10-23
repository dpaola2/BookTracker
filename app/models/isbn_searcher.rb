class IsbnSearcher
  attr_reader :book

  def initialize(book:)
    @book = book
  end

  def search
    book.isbn_search_results.destroy_all

    client = ISBNdb::ApiClient.new(api_key: ENV['ISBNDB_API_KEY'])

    begin
      isbn_results = client.book.batch("#{ book['title'] } #{ book['author'] }")[:books]
      
      isbn_results.map do |isbn_result|
        book.isbn_search_results.create!(
          isbn13: isbn_result[:isbn13],
          isbn10: isbn_result[:isbn10],
          title: isbn_result[:title],
          authors: isbn_result[:authors].join(","),
          image_url: isbn_result[:image]
        )
      end

      true
    rescue ISBNdb::RequestError => e
      false
    end

  end
end