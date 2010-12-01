desc "Resets this project"
task :reset do
  FileUtils.rm_r("#{RAILS_ROOT}/public/system/previews")
  FileUtils.rm("#{RAILS_ROOT}/db/development.sqlite3")
end