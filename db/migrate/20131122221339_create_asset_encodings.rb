class CreateAssetEncodings < ActiveRecord::Migration
  def change
    create_table :asset_encodings do |t|
      t.string :type
      t.string :uri
      t.integer :width
      t.integer :height
      t.integer :duration
      t.references :asset, index: true

      t.timestamps
    end
  end
end
