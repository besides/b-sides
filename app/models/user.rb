class User < ActiveRecord::Base
  authenticates_with_sorcery!
  
  has_many :authentications, :dependent => :destroy
  has_many :user_subscriptions, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  belongs_to :role

  def administrator?; self.role && self.role.name == "administrator"; end
  def artist?; self.role && self.role.name == "artist"; end
end
