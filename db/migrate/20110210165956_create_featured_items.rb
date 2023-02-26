class CreateFeaturedItems < ActiveRecord::Migration
  def self.up
    create_table :featured_items do |t|
      t.string :title
      t.text :content
      t.string :image

      t.timestamps
    end
  end

  def self.down
    drop_table :featured_items
  end
end
