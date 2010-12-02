class Story < ActiveRecord::Base
  acts_as_taggable

  def open
    increment!(:opens)
    update_attribute(:last_opened_at, DateTime.now)
  end

  def delete_original
    FileUtils.mkdir_p(File.dirname("#{Stories.deleted_dir}/#{path}"))
    File.rename(real_path, "#{Stories.deleted_dir}/#{path}")    
  end

  def self.sort_key(title)
    title.gsub(/[^A-Za-z0-9]+/, '').downcase
  end

  COMPRESSED_FILE_EXTS = %w(.zip)
  HTML_EXTS = %w(.htm .html)
  KRAMDOWN_EXTS = %w(.txt)
  ORDINARY_FILE_EXTS = HTML_EXTS + KRAMDOWN_EXTS
  VALID_EXTS = COMPRESSED_FILE_EXTS + ORDINARY_FILE_EXTS #Add rtf later

  #Iterate recursively over all files/dirs
  #If current item is a zip/rar/cbr/cbz file, pull out first image and store zip filename as manga name and zip filename as filename to load.
  #Else if current item is a dir, and it contains images but no directories, store the dir name as the manga name as well as the load filename.
  #Else skip/recurse into dir.
  #Do not call more than once at a time
  def self.import_and_update
    #Requires GNU find 3.8 or above
    cmd = <<-CMD
cd #{File.escape_name(Stories.dir)} && find . \\( -type f \\( #{VALID_EXTS.map { |ext| "-iname '*#{ext}'" }.join(' -o ')} \\) \\)
CMD

    $stdout.puts #This makes it actually import; fuck knows why

    path_list = IO.popen(cmd) { |s| s.read }
    path_list = path_list.split("\n").map { |e| e.gsub(/^\.\//, '') }.reject { |e| e[0, 1] == '.' }

    path_list.each { |path| self.import(path) }
  end

  def self.import(relative_path)
    puts "relative_path: #{relative_path}"
    real_path = File.expand_path("#{Stories.dir}/#{relative_path}")    
    
    last_modified = File.mtime(real_path)

    books = []

    begin      
      if COMPRESSED_FILE_EXTS.include?(File.extname(relative_path))
        puts "Skipping compressed file #{relative_path}"
        return
        #books = data_from_compressed_file(real_path)
      elsif ORDINARY_FILE_EXTS.include?(File.extname(relative_path))
        books = [data_from_ordinary_file(real_path)]
      end      
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(Stories::Application.instance).send(:log_error, e)
      return
    end
    
    books.each do |book|
      title = book[:title].gsub(/_/, ' ')
      Story.create!(:title => title, :content => book[:content], :published_on => last_modified, :sort_key => Story.sort_key(title))
    end

    #FileUtils.rm(real_path) if File.exists?(real_path) 
  end

  def self.data_from_compressed_file(real_path)
    #...
    #if ZIP_EXTS.include?(File.extname(real_path))
    #  system("unzip #{File.escape_name(real_path)} -d #{File.escape_name(destination_dir)}")      
    #elsif RAR_EXTS.include?(File.extname(real_path))
    #  system("cd #{File.escape_name(destination_dir)} && unrar e #{File.escape_name(real_path)}")      
    #end    
  end
  
  def self.data_from_ordinary_file(real_path)
    { :title => File.basename(real_path), :content =>
      import_text(File.read(real_path), HTML_EXTS.include?(File.extname(real_path)) ? "html" : "kramdown") }
  end

  def self.import_text(text, parser)
    doc = Kramdown::Document.new(text, :parser => parser)
    normalize(doc.root)
    doc.to_kramdown
  end

  def self.normalize(element)
    element.children.map! do |child|      
      if [:xml_comment, :xml_pi, :comment, :raw].include?(child.type)
        normalize(child)
        child.children 
      elsif child.type == :html_element
        if child.value == 'br'
          child.type = :br
          child.value = ""
          child.options[:category] = :span
          
          child
        elsif child.children.empty?
          nil
        else
          normalize(child)
          child.children
        end
      else
        normalize(child)
        child
      end      
    end
    element.children.flatten!
    element.children.compact!
  end
end