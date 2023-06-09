require "test_helper"

class IsbnSearchesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get isbn_searches_create_url
    assert_response :success
  end

  test "should get show" do
    get isbn_searches_show_url
    assert_response :success
  end
end
