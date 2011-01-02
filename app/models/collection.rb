class Collection < ActiveRecord::Base
  self.establish_connection Stories::COLLECTION_DB_CONFIG
  
  serialize :config
  
  def path=(p)
    self[:path] = File.expand_path(p)
  end

  def exists?
    File.exists?(path) && File.exists?(stories_path)
  end

  def opened!
    update_attribute(:last_opened_at, DateTime.now)
  end

  def self.most_recently_used
    self.order("last_opened_at DESC").first
  end
end