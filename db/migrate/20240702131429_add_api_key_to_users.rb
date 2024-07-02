class AddApiKeyToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :api_key, :string
    add_index :users, :api_key, unique: true

    User.all.each do |user|
      user.generate_api_key
      user.save
    end
  end
end
