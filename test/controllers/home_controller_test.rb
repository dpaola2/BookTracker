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

  test "shows recent books per shelf and recently updated" do
    @user.books.create!(title: "Dashboard Recent Book", shelf: shelves(:one))

    get root_url

    assert_match "Dashboard Recent Book", response.body
    assert_match shelves(:one).name, response.body
    assert_match "Recently updated", response.body
  end

  test "requires authentication" do
    sign_out @user
    get root_url

    assert_redirected_to new_user_session_url
  end
end
