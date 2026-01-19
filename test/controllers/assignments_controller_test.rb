require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @book = books(:one)
    @isbn_search_result = isbn_search_results(:one)
  end

  test "should create assignment and redirect to book" do
    # Skip: IsbnAssigner.assign makes real HTTP requests to download images.
    # This test needs WebMock or VCR to properly stub the network call.
    skip "Requires HTTP mocking for image download"
    post book_isbn_search_assignments_url(@book, @isbn_search_result)
    assert_redirected_to book_path(@book)
  end
end
