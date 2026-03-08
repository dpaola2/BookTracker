require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @book = books(:one)
  end

  test "should get index" do
    get books_url

    assert_response :success
  end

  test "should get new" do
    get new_book_url

    assert_response :success
  end

  test "should create book" do
    assert_difference("Book.count") do
      post books_url, params: { book: { author: @book.author, isbn: @book.isbn, title: @book.title, shelf_id: shelves(:one).id } }
    end

    assert_redirected_to book_url(Book.last)
  end

  test "should show book" do
    get book_url(@book)

    assert_response :success
  end

  test "should get edit" do
    get edit_book_url(@book)

    assert_response :success
  end

  test "should update book" do
    patch book_url(@book), params: { book: { author: @book.author, isbn: @book.isbn, title: @book.title } }

    assert_redirected_to book_url(@book)
  end

  test "should destroy book" do
    assert_difference("Book.count", -1) do
      delete book_url(@book)
    end

    assert_redirected_to books_url
  end

  test "cannot access another users book" do
    other_user = users(:two)
    other_shelf = Shelf.create!(name: "Other Shelf", user: other_user)
    other_book = Book.create!(title: "Other Book", author: "Other", user: other_user, shelf: other_shelf)

    assert_raises(ActiveRecord::RecordNotFound) do
      get book_url(other_book)
    end
  end

  test "requires authentication" do
    sign_out @user
    get books_url

    assert_redirected_to new_user_session_url
  end
end
