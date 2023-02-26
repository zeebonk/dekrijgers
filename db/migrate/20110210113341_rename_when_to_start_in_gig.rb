class RenameWhenToStartInGig < ActiveRecord::Migration
  def self.up
    rename_column :gigs, :when, :start
  end

  def self.down
    rename_column :gigs, :start, :when
  end
end
