require "test_helper"

module Api
  module V1
    class ShelvesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = User.create!(email: "shelves_api@example.com", password: "password123")
        @shelf = Shelf.create!(name: "My Shelf", user: @user)
        @book = Book.create!(title: "Shelf Book", author: "Author", isbn: "111", user: @user, shelf: @shelf)

        @other_user = User.create!(email: "other_shelves@example.com", password: "password123")
        @other_shelf = Shelf.create!(name: "Other Shelf", user: @other_user)
      end

      # -- index --

      test "index returns all shelves for authenticated user" do
        get api_v1_shelves_url, params: { api_key: @user.api_key, user_id: @user.id }

        assert_response :success
        json = response.parsed_body

        assert_equal @user.email, json["user"]
        assert_equal 1, json["shelves"].length
        assert_equal "My Shelf", json["shelves"].first["name"]
        assert_equal 1, json["shelves"].first["book_count"]
      end

      test "index does not include other users shelves" do
        get api_v1_shelves_url, params: { api_key: @user.api_key, user_id: @user.id }

        shelf_names = response.parsed_body["shelves"].map { |s| s["name"] }

        assert_not_includes shelf_names, "Other Shelf"
      end

      test "index returns 401 without credentials" do
        get api_v1_shelves_url

        assert_response :unauthorized
      end

      # -- show --

      test "show returns shelf with books" do
        get api_v1_shelf_url(@shelf), params: { api_key: @user.api_key, user_id: @user.id }

        assert_response :success
        json = response.parsed_body

        assert_equal "My Shelf", json["shelf"]["name"]
        assert_equal 1, json["shelf"]["books"].length
        assert_equal "Shelf Book", json["shelf"]["books"].first["title"]
      end

      test "show returns 404 for non-existent shelf" do
        get api_v1_shelf_url(id: 999_999), params: { api_key: @user.api_key, user_id: @user.id }

        assert_response :not_found
        assert_equal "Shelf not found", response.parsed_body["error"]
      end

      test "show returns 404 for another users shelf" do
        get api_v1_shelf_url(@other_shelf), params: { api_key: @user.api_key, user_id: @user.id }

        assert_response :not_found
      end

      test "show returns 401 with invalid api key" do
        get api_v1_shelf_url(@shelf), params: { api_key: "bad_key", user_id: @user.id }

        assert_response :unauthorized
      end
    end
  end
end
