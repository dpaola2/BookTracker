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
class Shelf < ApplicationRecord
  has_many :books
  belongs_to :user
end
