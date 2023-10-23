class IsbnAssigner
  attr_reader :book, :isbn_search_result

  def initialize(book:, isbn_search_result:)
    @book = book
    @isbn_search_result = isbn_search_result
  end

  def assign
    if isbn_search_result.book.update(
      isbn: isbn_search_result.isbn13,
      title: isbn_search_result.title,
      author: isbn_search_result.authors
    )

      url = URI.parse(isbn_search_result.image_url)
      filename = File.basename(url.path)
      file = URI.open(url)
      isbn_search_result.book.image.attach(io: file, filename: filename)

      true
    else
      false
    end
  end
end