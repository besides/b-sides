class RenameUserSubscriptionToPlural < ActiveRecord::Migration
  def self.up
    rename_table :user_subscription, :user_subscriptions
  end

 def self.down
    rename_table :user_subscriptions, :user_subscription
 end
end
