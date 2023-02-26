class AddPasswordToAdministrator < ActiveRecord::Migration
  def self.up
    add_column :administrators, :password, :string
  end

  def self.down
    remove_column :administrators, :password
  end
end
