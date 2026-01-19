require "test_helper"

class DefaultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @shelf = shelves(:one)
  end

  test "should set default shelf and redirect" do
    post shelf_defaults_url(@shelf)
    assert_redirected_to shelf_url(@shelf)
  end
end
