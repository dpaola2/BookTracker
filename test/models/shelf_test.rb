require "test_helper"

class ShelfTest < ActiveSupport::TestCase
  test "belongs to a user" do
    shelf = shelves(:one)

    assert_equal users(:one), shelf.user
  end

  test "has many books" do
    shelf = shelves(:one)

    assert_includes shelf.books, books(:one)
  end

  test "can be created with a name and user" do
    shelf = Shelf.new(name: "New Shelf", user: users(:one))

    assert_predicate shelf, :valid?
  end
end
