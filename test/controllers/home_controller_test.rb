require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "root renders the dashboard" do
    get root_url

    assert_response :success
    assert_match "Library", response.body
  end

  test "shows library stats" do
    @user.books.create!(title: "Dune Dashboard Test", shelf: shelves(:one),
                        classification: "fiction", genres: "Science Fiction")

    get root_url

    assert_match "Fiction", response.body
    assert_match "Nonfiction", response.body
    assert_match "Science Fiction", response.body
  end

  test "shows recent books per shelf and recently added" do
    @user.books.create!(title: "Dashboard Recent Book", shelf: shelves(:one))

    get root_url

    assert_match "Dashboard Recent Book", response.body
    assert_match shelves(:one).name, response.body
    assert_match "Recently added", response.body
    assert_no_match "Recently updated", response.body
  end

  test "shows the currently reading hero when an in-progress shelf exists" do
    reading_shelf = Shelf.create!(name: "📖 In Progress", user: @user)
    @user.books.create!(title: "Book Being Read Now", shelf: reading_shelf)

    get root_url

    assert_match "Book Being Read Now", response.body
    assert_match "In Progress", response.body
  end

  test "collapses inactive shelves to a count row without listing books" do
    dusty_shelf = Shelf.create!(name: "Dusty Archive", user: @user)
    @user.books.create!(title: "Forgotten Tome", shelf: dusty_shelf, created_at: 8.months.ago)
    10.times { |i| @user.books.create!(title: "Fresh Book #{i}", shelf: shelves(:one)) }

    get root_url

    assert_match "Dusty Archive", response.body
    assert_no_match "Forgotten Tome", response.body
  end

  test "requires authentication" do
    sign_out @user
    get root_url

    assert_redirected_to new_user_session_url
  end
end
