# == Schema Information
#
# Table name: shelves
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
require "test_helper"

class ShelfTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
