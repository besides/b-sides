class UserSubscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :artist, :class => User
  validates_presense_of :expires
end
