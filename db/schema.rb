# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110311143908) do

  create_table "stories", :force => true do |t|
    t.string   "title",               :limit => 500
    t.text     "content"
    t.integer  "opens",                              :default => 0
    t.integer  "word_count",                         :default => 0
    t.integer  "byte_size",                          :default => 0
    t.datetime "published_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "win",                                :default => false
    t.boolean  "fail",                               :default => false
    t.datetime "last_opened_at"
    t.string   "sort_key"
    t.text     "most_frequent_words"
    t.integer  "offset",                             :default => 0
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
