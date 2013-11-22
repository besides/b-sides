class User < ActiveRecord::Base
  authenticates_with_sorcery!
  
  has_many :providers, :class_name => "UserProvider", :dependent => :destroy
  has_many :user_subscriptions
  accepts_nested_attributes_for :providers

  belongs_to :role

  def administrator?; self.role && self.role.name == "administrator"; end
  def artist?; self.role && self.role.name == "artist"; end
end
