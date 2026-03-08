require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "belongs to a user" do
    book = books(:one)

    assert_equal users(:one), book.user
  end

  test "belongs to a shelf" do
    book = books(:one)

    assert_equal shelves(:one), book.shelf
  end

  test "has many isbn_search_results" do
    book = books(:one)

    assert_includes book.isbn_search_results, isbn_search_results(:one)
    assert_includes book.isbn_search_results, isbn_search_results(:two)
  end

  test "destroys isbn_search_results when destroyed" do
    book = books(:one)
    result_ids = book.isbn_search_results.pluck(:id)

    assert_not_empty result_ids

    book.destroy!

    result_ids.each do |id|
      assert_nil IsbnSearchResult.find_by(id: id)
    end
  end

  test "ransackable_attributes returns title author and isbn" do
    assert_equal %w[title author isbn], Book.ransackable_attributes
  end
end
