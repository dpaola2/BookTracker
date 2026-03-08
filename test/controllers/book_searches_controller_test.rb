require "test_helper"

class BookSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get book_searches_url

    assert_response :success
  end

  test "should search books by title" do
    get book_searches_url, params: { q: { title_cont: "MyString" } }

    assert_response :success
  end

  test "requires authentication" do
    sign_out @user
    get book_searches_url

    assert_redirected_to new_user_session_url
  end
end
