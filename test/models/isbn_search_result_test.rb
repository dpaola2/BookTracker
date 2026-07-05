# == Schema Information
#
# Table name: isbn_search_results
#
#  id             :integer          not null, primary key
#  authors        :string
#  date_published :string
#  image_url      :string
#  isbn10         :string
#  isbn13         :string
#  pages          :integer
#  subjects       :string
#  synopsis       :text
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  book_id        :integer
#
require "test_helper"

class IsbnSearchResultTest < ActiveSupport::TestCase
  test "belongs to a book" do
    result = isbn_search_results(:one)

    assert_equal books(:one), result.book
  end

  test "stores isbn metadata" do
    result = isbn_search_results(:one)

    assert_equal "9781234567890", result.isbn13
    assert_equal "1234567890", result.isbn10
    assert_equal "Test Book One", result.title
    assert_equal "Test Author", result.authors
    assert_equal "https://via.placeholder.com/150", result.image_url
  end
end
