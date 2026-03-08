require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @book = books(:one)
    @isbn_search_result = isbn_search_results(:one)
  end

  test "should create assignment and redirect to book" do
    mock_assigner = Minitest::Mock.new
    mock_assigner.expect(:assign, true)

    IsbnAssigner.stub(:new, mock_assigner) do
      post book_isbn_search_assignments_url(@book, @isbn_search_result)
    end

    assert_redirected_to book_path(@book)
    assert_equal "Book was successfully assigned.", flash[:notice]
  end

  test "requires authentication" do
    sign_out @user
    post book_isbn_search_assignments_url(@book, @isbn_search_result)

    assert_redirected_to new_user_session_url
  end
end
