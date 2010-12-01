task :import_and_update do
  require 'config/environment'
  Book.import_and_update
end