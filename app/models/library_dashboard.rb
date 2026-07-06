# Aggregates a user's library stats for the homepage dashboard.
class LibraryDashboard
  # Shelves with no additions inside this window collapse to count-only rows.
  ACTIVE_WINDOW = 6.months

  # The "currently reading" shelf is found by name until read status is
  # first-class data (see doc/ROADMAP.md, Priority 2).
  READING_SHELF_PATTERN = /in progress/i

  ShelfSummary = Struct.new(:shelf, :book_count, :recent_books, :latest_added_at, keyword_init: true)

  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def book_count
    user.books.count
  end

  def shelf_count
    user.shelves.count
  end

  def fiction_count
    user.books.where(classification: "fiction").count
  end

  def nonfiction_count
    user.books.where(classification: "nonfiction").count
  end

  def unclassified_count
    user.books.where(classification: nil).count
  end

  def top_genres(limit: 8)
    user.books.where.not(genres: [nil, ""])
        .pluck(:genres)
        .flat_map { |genres| genres.split(",").map(&:strip) }
        .tally
        .sort_by { |genre, count| [-count, genre] }
        .first(limit)
  end

  def recently_added(limit: 10)
    user.books.order(created_at: :desc).limit(limit)
  end

  def currently_reading
    shelf = reading_shelf
    return nil unless shelf

    [shelf, shelf.books.order(created_at: :desc).to_a]
  end

  def shelf_summaries(recent_limit: 3)
    user.shelves
        .reject { |shelf| shelf == reading_shelf }
        .filter_map { |shelf| summarize(shelf, recent_limit) }
        .sort_by { |summary| -summary.latest_added_at.to_i }
  end

  private

  def reading_shelf
    return @reading_shelf if defined?(@reading_shelf)

    @reading_shelf = user.shelves.detect { |shelf| shelf.name =~ READING_SHELF_PATTERN }
  end

  def summarize(shelf, recent_limit)
    newest = shelf.books.order(created_at: :desc).first
    return nil unless newest

    active = newest.created_at >= ACTIVE_WINDOW.ago

    ShelfSummary.new(
      shelf: shelf,
      book_count: shelf.books.count,
      recent_books: active ? shelf.books.order(created_at: :desc).limit(recent_limit).to_a : [],
      latest_added_at: newest.created_at
    )
  end
end
