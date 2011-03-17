class AddOffset < ActiveRecord::Migration
  def self.up
    add_column :stories, :offset, :integer, :default => 0
  end

  def self.down
    remove_column :stories, :offset
  end
end
