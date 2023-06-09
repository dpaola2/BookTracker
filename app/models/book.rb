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
#
class Book < ApplicationRecord
  belongs_to :shelf
  has_many :isbn_search_results, dependent: :destroy

  has_one_attached :image
end
