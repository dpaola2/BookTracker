# == Schema Information
#
# Table name: books
#
#  id         :bigint           not null, primary key
#  author     :string
#  isbn       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  shelf_id   :integer
#  user_id    :integer
#
class Book < ApplicationRecord
  validates :user_id, presence: true

  belongs_to :shelf
  belongs_to :user
  has_many :isbn_search_results, dependent: :destroy

  has_one_attached :image
  has_rich_text :comments

  def self.ransackable_attributes(auth_object = nil)
    ["title", "author", "isbn"]
  end
end
