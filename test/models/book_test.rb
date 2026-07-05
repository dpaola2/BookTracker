# == Schema Information
#
# Table name: books
#
#  id             :integer          not null, primary key
#  author         :string
#  classification :string
#  genres         :string
#  isbn           :string
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  shelf_id       :integer
#  user_id        :integer
#
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

  test "ransackable_attributes returns title author isbn classification and genres" do
    assert_equal %w[title author isbn classification genres], Book.ransackable_attributes
  end

  test "classification accepts fiction, nonfiction, and nil" do
    book = books(:one)

    book.classification = "fiction"

    assert_predicate book, :valid?

    book.classification = "nonfiction"

    assert_predicate book, :valid?

    book.classification = nil

    assert_predicate book, :valid?
  end

  test "classification rejects other values" do
    book = books(:one)
    book.classification = "poetry"

    assert_not_predicate book, :valid?
  end

  test "genre_list splits the genres string" do
    book = books(:one)
    book.genres = "Science Fiction, Fantasy"

    assert_equal ["Science Fiction", "Fantasy"], book.genre_list
  end

  test "genre_list is empty when genres is blank" do
    book = books(:one)
    book.genres = nil

    assert_empty book.genre_list
  end

  test "GENRES is a controlled vocabulary including Science Fiction" do
    assert_includes Book::GENRES, "Science Fiction"
  end
end
