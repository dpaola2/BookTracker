# Aggregates a user's library stats for the homepage dashboard.
class LibraryDashboard
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

  def recently_updated(limit: 10)
    user.books.order(updated_at: :desc).limit(limit)
  end

  def shelves_with_recent_books(limit: 10)
    user.shelves
        .sort_by { |shelf| -shelf.books.count }
        .map { |shelf| [shelf, shelf.books.order(created_at: :desc).limit(limit).to_a] }
        .reject { |_shelf, books| books.empty? }
  end
end
