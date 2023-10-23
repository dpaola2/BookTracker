class IsbnSearcher
  attr_reader :book, :client

  def initialize(book:)
    @book = book
    @client = ISBNdb::ApiClient.new(api_key: ENV['ISBNDB_API_KEY'])
  end

  def search
    book.isbn_search_results.destroy_all

    begin
      isbn_results = client.book.batch("#{ book['title'] } #{ book['author'] }")[:books]
      
      isbn_results.map do |isbn_result|
        result_from_hash(book: book, isbn_result: isbn_result)
      end

      true
    rescue ISBNdb::RequestError => e
      false
    end

  end

  def find_by_isbn
    book.isbn_search_results.destroy_all

    begin
      isbn_result = client.book.find(book.isbn)
      result_from_hash(book: book, isbn_result: isbn_result[:book])
    rescue ISBNdb::RequestError => e
      false
    end
  end

  def result_from_hash(book:, isbn_result:)
    book.isbn_search_results.create!(
      isbn13: isbn_result[:isbn13],
      isbn10: isbn_result[:isbn10],
      title: isbn_result[:title],
      authors: isbn_result[:authors].join(","),
      image_url: isbn_result[:image]
    )
  end
end