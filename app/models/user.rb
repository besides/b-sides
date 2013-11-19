require 'bcrypt'
class User < ActiveRecord::Base
  #attr_accessible :email, :providers_attributes

  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

  validates :email, uniqueness: true


  
  has_many :providers, :class_name => "UserProvider", :dependent => :destroy
  has_many :user_asset_purchases
  has_many :assets
  accepts_nested_attributes_for :providers

  attr_accessible :email, :password, :password_confirmation, :providers_attributes

  belongs_to :role

end
