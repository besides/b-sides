class NoUserPasswords < ActiveRecord::Migration
  def change
    remove_column :users, :crypted_password
    remove_column :users, :salt
  end
end
