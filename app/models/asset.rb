# An asset belongs to an artist (User) and has a URI from which it was loaded
class Asset < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :uri
end
