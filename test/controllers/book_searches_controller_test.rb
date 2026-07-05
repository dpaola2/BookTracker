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

  test "filters books by classification" do
    @user.books.create!(title: "Project Hail Mary", author: "Andy Weir",
                        classification: "fiction", genres: "Science Fiction", shelf: shelves(:one))
    @user.books.create!(title: "The Mom Test", author: "Rob Fitzpatrick",
                        classification: "nonfiction", genres: "Business", shelf: shelves(:one))

    get book_searches_url, params: { q: { classification_eq: "fiction" } }

    assert_response :success
    assert_match "Project Hail Mary", response.body
    assert_no_match "The Mom Test", response.body
  end

  test "filters books by genre" do
    @user.books.create!(title: "Project Hail Mary", author: "Andy Weir",
                        classification: "fiction", genres: "Science Fiction", shelf: shelves(:one))
    @user.books.create!(title: "Dune", author: "Frank Herbert",
                        classification: "fiction", genres: "Science Fiction,Fantasy", shelf: shelves(:one))
    @user.books.create!(title: "The Mom Test", author: "Rob Fitzpatrick",
                        classification: "nonfiction", genres: "Business", shelf: shelves(:one))

    get book_searches_url, params: { q: { genres_cont: "Science Fiction" } }

    assert_response :success
    assert_match "Project Hail Mary", response.body
    assert_match "Dune", response.body
    assert_no_match "The Mom Test", response.body
  end

  test "combines genre and classification filters with text search" do
    @user.books.create!(title: "Project Hail Mary", author: "Andy Weir",
                        classification: "fiction", genres: "Science Fiction", shelf: shelves(:one))
    @user.books.create!(title: "Dune", author: "Frank Herbert",
                        classification: "fiction", genres: "Science Fiction", shelf: shelves(:one))

    get book_searches_url, params: { q: { genres_cont: "Science Fiction", title_i_cont: "dune" } }

    assert_response :success
    assert_match "Dune", response.body
    assert_no_match "Project Hail Mary", response.body
  end

  test "requires authentication" do
    sign_out @user
    get book_searches_url

    assert_redirected_to new_user_session_url
  end
end
