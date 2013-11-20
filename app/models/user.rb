require 'bcrypt'
class User < ActiveRecord::Base
  authenticates_with_sorcery!
  
  has_many :providers, :class_name => "UserProvider", :dependent => :destroy
  has_many :user_subscriptions
  accepts_nested_attributes_for :providers

  attr_accessible :email, :name, :providers_attributes

  belongs_to :role

end
