require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "generates api_key on create" do
    user = User.create!(email: "newuser@example.com", password: "password123")

    assert_not_nil user.api_key
    assert_equal 40, user.api_key.length
  end

  test "does not overwrite existing api_key on create" do
    user = User.new(email: "newuser@example.com", password: "password123", api_key: "custom_key")
    user.save!

    assert_equal "custom_key", user.api_key
  end

  test "has many books" do
    user = users(:one)

    assert_respond_to user, :books
    assert_includes user.books, books(:one)
  end

  test "has many shelves" do
    user = users(:one)

    assert_respond_to user, :shelves
    assert_includes user.shelves, shelves(:one)
  end

  test "can have a default shelf" do
    user = users(:one)

    assert_equal shelves(:one), user.default_shelf
  end

  test "default shelf is optional" do
    user = users(:two)

    assert_nil user.default_shelf
  end

  test "requires email" do
    user = User.new(password: "password123")

    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires unique email" do
    User.create!(email: "taken@example.com", password: "password123")
    duplicate = User.new(email: "taken@example.com", password: "password123")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "requires password with minimum length" do
    user = User.new(email: "test@example.com", password: "short")

    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end
end
