# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Stories::Application.initialize!

db_config = { :adapter => 'sqlite3', :pool => 5, :timeout => 5000, :database => "#{Stories.dir}/db.sqlite3" }
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Migrator.migrate("db/migrate/")
ActiveRecord::Base.establish_connection(db_config)

#%w(open gnome-open).detect { |app| system("#{app} http://localhost:30813/") } unless $0 =~ /^rake|irb$/
