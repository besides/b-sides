class UserEmailIsName < ActiveRecord::Migration
  def change
    User.delete_all
    Authentication.delete_all
    add_column :users, :name, :string, :default => nil
  end
end
