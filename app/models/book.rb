# == Schema Information
#
# Table name: books
#
#  id             :integer          not null, primary key
#  author         :string
#  classification :string
#  genres         :string
#  isbn           :string
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  shelf_id       :integer
#  user_id        :integer
#
class Book < ApplicationRecord
  CLASSIFICATIONS = %w[fiction nonfiction].freeze

  GENRES = [
    "Science Fiction", "Fantasy", "Mystery & Thriller", "Literary Fiction",
    "Historical Fiction", "Horror", "Romance", "Short Stories",
    "Business", "Programming & Technical", "Science", "History",
    "Biography & Memoir", "Self-Help", "Cooking", "Essays", "Philosophy",
    "Psychology", "Politics & Society", "True Crime", "Poetry", "Reference",
    "Parenting", "Health & Fitness", "Travel", "Art & Design", "Other"
  ].freeze

  belongs_to :shelf
  belongs_to :user
  has_many :isbn_search_results, dependent: :destroy

  has_one_attached :image
  has_rich_text :comments

  validates :classification, inclusion: { in: CLASSIFICATIONS }, allow_nil: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[title author isbn classification genres]
  end

  def genre_list
    genres.to_s.split(",").map(&:strip).reject(&:empty?)
  end
end
