require "test_helper"

class IsbnSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @book = books(:one)
  end

  test "should create isbn search and redirect to book" do
    post book_isbn_searches_url(@book)
    assert_redirected_to book_url(@book)
  end
end
