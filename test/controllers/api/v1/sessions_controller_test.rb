require "test_helper"

module Api
  module V1
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = User.create!(email: "session@example.com", password: "password123")
      end

      test "returns user_id and api_key with valid credentials" do
        post api_v1_sessions_url, params: { email: @user.email, password: "password123" }

        assert_response :success
        json = response.parsed_body

        assert_equal @user.id, json["user_id"]
        assert_equal @user.api_key, json["api_key"]
      end

      test "returns 401 with invalid email" do
        post api_v1_sessions_url, params: { email: "wrong@example.com", password: "password123" }

        assert_response :unauthorized
        assert_equal "Invalid email or password", response.parsed_body["error"]
      end

      test "returns 401 with invalid password" do
        post api_v1_sessions_url, params: { email: @user.email, password: "wrongpassword" }

        assert_response :unauthorized
        assert_equal "Invalid email or password", response.parsed_body["error"]
      end

      test "returns 401 with no credentials" do
        post api_v1_sessions_url

        assert_response :unauthorized
      end
    end
  end
end
