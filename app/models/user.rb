# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  api_key                :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  shelf_id               :integer
#
# Indexes
#
#  index_users_on_api_key               (api_key) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  before_create :generate_api_key

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_many :books
  belongs_to :default_shelf, foreign_key: :shelf_id, class_name: "Shelf", optional: true
  has_many :shelves
  
  def generate_api_key
    self.api_key = SecureRandom.hex(20) unless self.api_key.present?
  end
end
