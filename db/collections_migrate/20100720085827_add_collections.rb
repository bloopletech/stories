class AddCollections < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
      t.string :path
      t.string :config
      t.datetime :last_opened_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :collections
  end
end
