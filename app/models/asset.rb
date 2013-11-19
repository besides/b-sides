class Asset < ActiveRecord::Base
  belongs_to :user
  has_many :user_asset_purchases
  attr_accessible :user_id, :uri
end
