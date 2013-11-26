class Authentication < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :uid, :provider
end