# == Schema Information
#
# Table name: isbn_search_results
#
#  id         :bigint           not null, primary key
#  authors    :string
#  image_url  :string
#  isbn10     :string
#  isbn13     :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :integer
#
class IsbnSearchResult < ApplicationRecord
  belongs_to :book
end
