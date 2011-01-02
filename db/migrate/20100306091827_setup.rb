class Setup < ActiveRecord::Migration
  def self.up
    create_table "stories", :force => true do |t|
      t.string   "title",          :limit => 500
      t.text     "content"
      t.integer  "opens",                         :default => 0
      t.integer  "word_count",                         :default => 0
      t.integer  "byte_size",                         :default => 0
      t.datetime "published_on"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "win",                           :default => false
      t.boolean  "fail",                          :default => false
      t.datetime "last_opened_at"
      t.string   "sort_key"
    end
    
    create_table "collections", :force => true do |t|
      t.string   "path"
      t.string   "config"
      t.datetime "last_opened_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "taggings", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "taggable_type"
      t.string   "context"
      t.datetime "created_at"
    end
    
    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"
    
    create_table "tags", :force => true do |t|
      t.string "name"
    end
  end

  def self.down
  end
end
