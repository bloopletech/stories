require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

require 'fileutils'

ActsAsTaggableOn::TagList.delimiter = ' '

Time::DATE_FORMATS.merge!(:default => '%e %B %Y') #TODO fix so shows time as well
Date::DATE_FORMATS.merge!(:default => '%e %B %Y')

module Stories
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end


  DEFAULT_DB_CONFIG = { :adapter => 'sqlite3', :pool => 5, :timeout => 5000 }
  COLLECTION_DB_CONFIG = DEFAULT_DB_CONFIG.merge(:database => File.expand_path("~/.stories.sqlite3"))

  mattr_accessor :collection, :dir, :stories_dir

  def self.configure(collection)
    Stories.collection = collection
    Stories.dir = collection.path
    Stories.stories_dir = collection.stories_path

    Dir.mkdir(Stories.stories_dir) if !File.exists?(Stories.stories_dir)

    important_filename = "#{Stories.dir}/IMPORTANT!!! - DO NOT DELETE.txt"
    #if !File.exists?(important_filename)
      File.open(important_filename, "w") do |f|
        f << <<-EOF
THIS DIRECTORY IS NOT EMPTY.

THERE ARE STORIES STORED IN THE HIDDEN FOLDER #{Stories.stories_dir} - DELETING THIS DIRECTORY WILL DELETE THESE STORIES.
EOF
      end
    #end
    
    db_config = DEFAULT_DB_CONFIG.merge(:database => "#{Stories.stories_dir}/db.sqlite3")

    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Migrator.migrate("db/migrate/")
    ActiveRecord::Base.establish_connection(db_config)

    collection.opened!
  end
end

require Rails.root.join('lib/file_extensions')
require Rails.root.join('lib/nsf')