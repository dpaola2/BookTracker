# == Schema Information
#
# Table name: isbn_search_results
#
#  id         :integer          not null, primary key
#  authors    :string
#  image_url  :string
#  isbn10     :string
#  isbn13     :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :integer
#
require "test_helper"

class IsbnSearchResultTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
