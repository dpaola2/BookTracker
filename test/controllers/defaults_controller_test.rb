require "test_helper"

class DefaultsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get defaults_create_url
    assert_response :success
  end
end
