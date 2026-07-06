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

  test "recently_added returns newest additions first with a limit" do
    oldest = @user.books.create!(title: "Oldest", shelf: @scifi_shelf, created_at: 2.days.ago)
    newest = @user.books.create!(title: "Newest", shelf: @scifi_shelf, created_at: 1.minute.ago)
    oldest.update!(updated_at: Time.current)

    assert_equal [newest, oldest], @dashboard.recently_added
    assert_equal [newest], @dashboard.recently_added(limit: 1)
  end

  test "currently_reading finds the in-progress shelf by name" do
    reading_shelf = Shelf.create!(name: "📖 In Progress", user: @user)
    book = @user.books.create!(title: "Current Read", shelf: reading_shelf)

    shelf, books = @dashboard.currently_reading

    assert_equal reading_shelf, shelf
    assert_equal [book], books
  end

  test "currently_reading is nil when no in-progress shelf exists" do
    assert_nil @dashboard.currently_reading
  end

  test "shelf_summaries orders shelves by most recent addition with newest books" do
    @user.books.create!(title: "Old Scifi", shelf: @scifi_shelf, created_at: 3.days.ago)
    @user.books.create!(title: "Biz", shelf: @biz_shelf, created_at: 2.days.ago)
    newest = @user.books.create!(title: "New Scifi", shelf: @scifi_shelf, created_at: 1.minute.ago)

    result = @dashboard.shelf_summaries

    assert_equal [@scifi_shelf, @biz_shelf], result.map(&:shelf)
    assert_equal newest, result.first.recent_books.first
    assert_equal 2, result.first.book_count
  end

  test "shelf_summaries limits recent books per shelf" do
    5.times { |i| @user.books.create!(title: "Scifi #{i}", shelf: @scifi_shelf) }

    result = @dashboard.shelf_summaries(recent_limit: 3)

    assert_equal 3, result.first.recent_books.length
    assert_equal 5, result.first.book_count
  end

  test "shelf_summaries collapses inactive shelves to count-only" do
    @user.books.create!(title: "Dusty", shelf: @biz_shelf, created_at: 7.months.ago)
    @user.books.create!(title: "Fresh", shelf: @scifi_shelf)

    result = @dashboard.shelf_summaries

    biz_summary = result.find { |s| s.shelf == @biz_shelf }

    assert_empty biz_summary.recent_books
    assert_equal 1, biz_summary.book_count

    scifi_summary = result.find { |s| s.shelf == @scifi_shelf }

    assert_not_empty scifi_summary.recent_books
  end

  test "shelf_summaries excludes the currently-reading shelf and empty shelves" do
    reading_shelf = Shelf.create!(name: "📖 In Progress", user: @user)
    @user.books.create!(title: "Current Read", shelf: reading_shelf)
    @user.books.create!(title: "Fresh", shelf: @scifi_shelf)

    result = @dashboard.shelf_summaries

    assert_equal [@scifi_shelf], result.map(&:shelf)
  end

  test "handles an empty library" do
    empty_user = User.create!(email: "empty@example.com", password: "password123")
    dashboard = LibraryDashboard.new(user: empty_user)

    assert_equal 0, dashboard.book_count
    assert_empty dashboard.top_genres
    assert_empty dashboard.recently_added
    assert_empty dashboard.shelf_summaries
    assert_nil dashboard.currently_reading
  end
end
