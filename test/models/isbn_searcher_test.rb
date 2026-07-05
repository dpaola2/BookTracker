require "test_helper"

class IsbnSearcherTest < ActiveSupport::TestCase
  setup do
    @book = books(:one)
    @searcher = IsbnSearcher.new(book: @book)
  end

  test "search clears existing isbn_search_results" do
    assert_not_empty @book.isbn_search_results

    mock_client = Minitest::Mock.new
    mock_book_client = Minitest::Mock.new
    mock_book_client.expect(:batch, { books: [] }, [String])
    mock_client.expect(:book, mock_book_client)

    @searcher.stub(:client, mock_client) do
      @searcher.search
    end

    assert_empty @book.isbn_search_results.reload
  end

  test "search returns true on success" do
    mock_client = Minitest::Mock.new
    mock_book_client = Minitest::Mock.new
    mock_book_client.expect(:batch, {
                              books: [
                                { isbn13: "9781111111111", isbn10: "1111111111", title: "Found Book", authors: ["Author A"], image: "http://example.com/img.jpg" }
                              ]
                            }, [String])
    mock_client.expect(:book, mock_book_client)

    result = @searcher.stub(:client, mock_client) do
      @searcher.search
    end

    assert result
  end

  test "search creates isbn_search_results from api response" do
    mock_client = Minitest::Mock.new
    mock_book_client = Minitest::Mock.new
    mock_book_client.expect(:batch, {
                              books: [
                                { isbn13: "9781111111111", isbn10: "1111111111", title: "Found Book", authors: ["Author A"], image: "http://example.com/img.jpg" }
                              ]
                            }, [String])
    mock_client.expect(:book, mock_book_client)

    @searcher.stub(:client, mock_client) do
      @searcher.search
    end

    result = @book.isbn_search_results.reload.last

    assert_equal "9781111111111", result.isbn13
    assert_equal "Found Book", result.title
    assert_equal "Author A", result.authors
  end

  test "search persists subjects synopsis pages and date_published" do
    mock_client = Minitest::Mock.new
    mock_book_client = Minitest::Mock.new
    mock_book_client.expect(:batch, {
                              books: [
                                {
                                  isbn13: "9781111111111", isbn10: "1111111111", title: "Found Book",
                                  authors: ["Author A"], image: "http://example.com/img.jpg",
                                  subjects: ["Science Fiction", "Space Opera"],
                                  synopsis: "A grand space adventure.",
                                  pages: 432,
                                  date_published: "2019"
                                }
                              ]
                            }, [String])
    mock_client.expect(:book, mock_book_client)

    @searcher.stub(:client, mock_client) do
      @searcher.search
    end

    result = @book.isbn_search_results.reload.last

    assert_equal "Science Fiction,Space Opera", result.subjects
    assert_equal "A grand space adventure.", result.synopsis
    assert_equal 432, result.pages
    assert_equal "2019", result.date_published
  end

  test "search tolerates results without extended metadata" do
    mock_client = Minitest::Mock.new
    mock_book_client = Minitest::Mock.new
    mock_book_client.expect(:batch, {
                              books: [
                                { isbn13: "9781111111111", isbn10: "1111111111", title: "Found Book", authors: ["Author A"], image: "http://example.com/img.jpg" }
                              ]
                            }, [String])
    mock_client.expect(:book, mock_book_client)

    @searcher.stub(:client, mock_client) do
      @searcher.search
    end

    result = @book.isbn_search_results.reload.last

    assert_nil result.subjects
    assert_nil result.pages
  end

  test "search returns false on api error" do
    mock_client = Minitest::Mock.new
    mock_book_client = Minitest::Mock.new
    mock_book_client.expect(:batch, nil) { raise ISBNdb::RequestError }
    mock_client.expect(:book, mock_book_client)

    result = @searcher.stub(:client, mock_client) do
      @searcher.search
    end

    assert_not result
  end

  test "find_by_isbn returns an isbn_search_result on success" do
    mock_client = Minitest::Mock.new
    mock_book_client = Minitest::Mock.new
    mock_book_client.expect(:find, {
                              book: { isbn13: "9782222222222", isbn10: "2222222222", title: "ISBN Book", authors: ["Author B"], image: "http://example.com/cover.jpg" }
                            }, [String])
    mock_client.expect(:book, mock_book_client)

    result = @searcher.stub(:client, mock_client) do
      @searcher.find_by_isbn
    end

    assert_instance_of IsbnSearchResult, result
    assert_equal "9782222222222", result.isbn13
  end

  test "find_by_isbn returns false on api error" do
    mock_client = Minitest::Mock.new
    mock_book_client = Minitest::Mock.new
    mock_book_client.expect(:find, nil) { raise ISBNdb::RequestError }
    mock_client.expect(:book, mock_book_client)

    result = @searcher.stub(:client, mock_client) do
      @searcher.find_by_isbn
    end

    assert_not result
  end
end
