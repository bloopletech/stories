# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Stories::Application.initialize!

#Migrate collections
ActiveRecord::Base.establish_connection(Stories::COLLECTION_DB_CONFIG)
ActiveRecord::Migrator.migrate("db/collections_migrate/")
ActiveRecord::Base.establish_connection(nil)

Stories.configure(Collection.most_recently_used) if Collection.most_recently_used && Collection.most_recently_used.exists?

#%w(open gnome-open).detect { |app| system("#{app} http://localhost:30813/") } unless $0 =~ /^rake|irb$/