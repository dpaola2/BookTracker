require "test_helper"

class IsbnAssignerTest < ActiveSupport::TestCase
  setup do
    @book = books(:one)
    @isbn_result = isbn_search_results(:one)
    @assigner = IsbnAssigner.new(book: @book, isbn_search_result: @isbn_result)
  end

  test "updates book metadata from isbn search result" do
    fake_file = StringIO.new("fake image data")

    @assigner.stub(:open_image, fake_file) do
      @assigner.assign
    end

    @book.reload

    assert_equal @isbn_result.isbn13, @book.isbn
    assert_equal @isbn_result.title, @book.title
    assert_equal @isbn_result.authors, @book.author
  end

  test "attaches image to book" do
    fake_file = StringIO.new("fake image data")

    @assigner.stub(:open_image, fake_file) do
      @assigner.assign
    end

    assert_predicate @book.reload.image, :attached?
  end

  test "returns true on success" do
    fake_file = StringIO.new("fake image data")

    result = @assigner.stub(:open_image, fake_file) do
      @assigner.assign
    end

    assert result
  end
end
