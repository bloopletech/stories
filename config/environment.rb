# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Stories::Application.initialize!

Stories::Application::DATABASE_PATH = "#{Stories.dir}/db.sqlite3" 

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :pool => 5, :timeout => 5000, :database => Stories::Application::DATABASE_PATH)
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/")

#%w(open gnome-open).detect { |app| system("#{app} http://localhost:30813/") } unless $0 =~ /^rake|irb$/
