class AddAlwaysShowTitle < ActiveRecord::Migration
  def self.up
    remove_column :collections, :config
    add_column :collections, :always_show_title, :boolean, :default => true
  end

  def self.down
    remove_column :collections, :always_show_title
    add_column :collections, :config, :string
  end
end
