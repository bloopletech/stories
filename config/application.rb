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

  mattr_accessor :collection, :dir, :import_dir, :export_dir

  def self.configure(collection)
    Stories.collection = collection
    Stories.dir = collection.path
    Stories.import_dir = "#{collection.path}/import"
    Stories.export_dir = "#{collection.path}/export"

    Dir.mkdir(import_dir) unless File.exists?(import_dir)
    Dir.mkdir(export_dir) unless File.exists?(export_dir)
    
    db_config = DEFAULT_DB_CONFIG.merge(:database => "#{Stories.dir}/stories-collection.sqlite3")

    ActiveRecord::Base.establish_connection(db_config)    
    ActiveRecord::Migrator.migrate("db/migrate/")
    ActiveRecord::Base.establish_connection(db_config)

    collection.opened!
  end
end

require Rails.root.join("config/version")

require Rails.root.join('lib/file_extensions')
require Rails.root.join('lib/future_file')
require Rails.root.join('lib/string_extensions')
require Rails.root.join('lib/numeric_extensions')

Nsf::Document::TEXT_TAGS.delete('a')