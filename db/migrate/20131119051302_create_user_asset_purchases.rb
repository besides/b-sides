class CreateUserAssetPurchases < ActiveRecord::Migration
  def change
    create_table :user_asset_purchases do |t|
      t.references :user, index: true
      t.references :asset, index: true

      t.timestamps
    end
  end
end
