require "test_helper"

class Api::V1::BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "test@example.com", password: "password123")
    @shelf = Shelf.create!(name: "Test Shelf", user: @user)
    @book = Book.create!(
      title: "Test Book",
      author: "Test Author",
      isbn: "1234567890",
      user: @user,
      shelf: @shelf
    )

    @other_user = User.create!(email: "other@example.com", password: "password123")
    @other_shelf = Shelf.create!(name: "Other Shelf", user: @other_user)
    @other_book = Book.create!(
      title: "Other Book",
      author: "Other Author",
      isbn: "0987654321",
      user: @other_user,
      shelf: @other_shelf
    )
  end

  test "should get book with valid credentials" do
    get api_v1_book_url(@book), params: { api_key: @user.api_key, user_id: @user.id }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @book.id, json_response["book"]["id"]
    assert_equal "Test Book", json_response["book"]["title"]
    assert_equal "Test Author", json_response["book"]["author"]
  end

  test "should return 404 for non-existent book" do
    get api_v1_book_url(id: 999999), params: { api_key: @user.api_key, user_id: @user.id }

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Book not found", json_response["error"]
  end

  test "should return 404 when accessing another user's book" do
    get api_v1_book_url(@other_book), params: { api_key: @user.api_key, user_id: @user.id }

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Book not found", json_response["error"]
  end

  test "should return 401 without api credentials" do
    get api_v1_book_url(@book)

    assert_response :unauthorized
  end

  test "should return 401 with invalid api key" do
    get api_v1_book_url(@book), params: { api_key: "invalid_key", user_id: @user.id }

    assert_response :unauthorized
  end
end
