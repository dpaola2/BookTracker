require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get assignments_create_url
    assert_response :success
  end
end
