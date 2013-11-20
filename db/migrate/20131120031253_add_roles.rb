class AddRoles < ActiveRecord::Migration
  def change
    %w(administrator artist).each do |name|
      Role.create {|r| r.name = name}
    end
  end
end
