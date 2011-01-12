class AddMfw < ActiveRecord::Migration
  def self.up
    add_column :stories, :most_frequent_words, :text\
    
    Story.all.each { |s| s.save(:validate => false) }
  end

  def self.down
    remove_column :stories, :most_frequent_words
  end
end
