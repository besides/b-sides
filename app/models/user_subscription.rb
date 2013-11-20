class UserSubscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :artist, class_name: "User"
  validates :expires, presence: true
end
