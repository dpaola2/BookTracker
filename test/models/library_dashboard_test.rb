require "test_helper"

class LibraryDashboardTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "dashboard@example.com", password: "password123")
    @scifi_shelf = Shelf.create!(name: "Scifi", user: @user)
    @biz_shelf = Shelf.create!(name: "Business", user: @user)
    @dashboard = LibraryDashboard.new(user: @user)
  end

  test "counts books and shelves for the user only" do
    @user.books.create!(title: "Dune", shelf: @scifi_shelf, classification: "fiction", genres: "Science Fiction")

    other_user = users(:one)

    assert_equal 1, @dashboard.book_count
    assert_equal 2, @dashboard.shelf_count
    assert_not_equal other_user.books.count, 0
  end

  test "counts by classification" do
    @user.books.create!(title: "Dune", shelf: @scifi_shelf, classification: "fiction", genres: "Science Fiction")
    @user.books.create!(title: "Hyperion", shelf: @scifi_shelf, classification: "fiction", genres: "Science Fiction")
    @user.books.create!(title: "The Mom Test", shelf: @biz_shelf, classification: "nonfiction", genres: "Business")
    @user.books.create!(title: "Mystery Book", shelf: @biz_shelf)

    assert_equal 2, @dashboard.fiction_count
    assert_equal 1, @dashboard.nonfiction_count
    assert_equal 1, @dashboard.unclassified_count
  end

  test "top_genres tallies comma-separated genres in descending order" do
    @user.books.create!(title: "Dune", shelf: @scifi_shelf, classification: "fiction", genres: "Science Fiction,Fantasy")
    @user.books.create!(title: "Hyperion", shelf: @scifi_shelf, classification: "fiction", genres: "Science Fiction")
    @user.books.create!(title: "The Mom Test", shelf: @biz_shelf, classification: "nonfiction", genres: "Business")

    assert_equal [["Science Fiction", 2], ["Business", 1], ["Fantasy", 1]].sort, @dashboard.top_genres.sort
    assert_equal ["Science Fiction", 2], @dashboard.top_genres.first
  end

  test "top_genres respects the limit" do
    @user.books.create!(title: "Dune", shelf: @scifi_shelf, classification: "fiction", genres: "Science Fiction,Fantasy,Horror")

    assert_equal 2, @dashboard.top_genres(limit: 2).length
  end

  test "recently_updated returns newest first with a limit" do
    oldest = @user.books.create!(title: "Oldest", shelf: @scifi_shelf)
    newest = @user.books.create!(title: "Newest", shelf: @scifi_shelf)
    oldest.update!(updated_at: 2.days.ago)
    newest.update!(updated_at: 1.minute.ago)

    assert_equal [newest, oldest], @dashboard.recently_updated
    assert_equal [newest], @dashboard.recently_updated(limit: 1)
  end

  test "shelves_with_recent_books returns each shelf with its newest books" do
    old_book = @user.books.create!(title: "Old Scifi", shelf: @scifi_shelf, created_at: 2.days.ago)
    new_book = @user.books.create!(title: "New Scifi", shelf: @scifi_shelf, created_at: 1.minute.ago)
    biz_book = @user.books.create!(title: "Biz", shelf: @biz_shelf)

    result = @dashboard.shelves_with_recent_books

    assert_equal 2, result.length

    scifi_entry = result.find { |shelf, _books| shelf == @scifi_shelf }

    assert_equal [new_book, old_book], scifi_entry.last

    biz_entry = result.find { |shelf, _books| shelf == @biz_shelf }

    assert_equal [biz_book], biz_entry.last
  end

  test "shelves_with_recent_books limits books per shelf and orders shelves by book count" do
    3.times { |i| @user.books.create!(title: "Scifi #{i}", shelf: @scifi_shelf) }
    @user.books.create!(title: "Biz", shelf: @biz_shelf)

    result = @dashboard.shelves_with_recent_books(limit: 2)

    assert_equal @scifi_shelf, result.first.first
    assert_equal 2, result.first.last.length
  end

  test "handles an empty library" do
    empty_user = User.create!(email: "empty@example.com", password: "password123")
    dashboard = LibraryDashboard.new(user: empty_user)

    assert_equal 0, dashboard.book_count
    assert_empty dashboard.top_genres
    assert_empty dashboard.recently_updated
    assert_empty dashboard.shelves_with_recent_books
  end
end
