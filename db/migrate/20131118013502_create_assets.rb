class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.references :user, index: true
      t.string :uri

      t.timestamps
    end
  end
end
