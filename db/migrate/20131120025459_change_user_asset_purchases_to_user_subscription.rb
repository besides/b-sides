class ChangeUserAssetPurchasesToUserSubscription < ActiveRecord::Migration
  def change
    # Users don't purchase assets, they purchase subscriptions to artists (who are also users)
    drop_table :user_asset_purchases

    # Associates a user with an artist (also a user) with an expiration time during which the user has full access to the artist's assets.
    create_table :user_subscription do |t|
      t.references :user, index: true
      t.references :artist, index: true
      t.datetime :expires

      t.timestamps
    end
  end
end
