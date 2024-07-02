# == Schema Information
#
# Table name: books
#
#  id         :integer          not null, primary key
#  author     :string
#  isbn       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  shelf_id   :integer
#  user_id    :integer
#
require "test_helper"

class BookTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
