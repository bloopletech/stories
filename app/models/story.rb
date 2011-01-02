class Story < ActiveRecord::Base
  acts_as_taggable

  validates_presence_of :title, :content

  before_save :update_stats

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
    import_directory(Stories.dir)
  end
  
  def self.import_directory(dir)
    #Requires GNU find 3.8 or above
    cmd = <<-CMD
cd #{File.escape_name(dir)} && find . \\( -type f \\( #{VALID_EXTS.map { |ext| "-iname '*#{ext}'" }.join(' -o ')} \\) \\)
CMD

    $stdout.puts #This makes it actually import; fuck knows why

    path_list = IO.popen(cmd) { |s| s.read }
    path_list = path_list.split("\n").map { |e| e.gsub(/^\.\//, '') }.reject { |e| e[0, 1] == '.' }

    path_list.each { |path| self.import("#{dir}/#{path}") }
  end

  def self.import(relative_path)
    real_path = relative_path
    
    last_modified = File.mtime(real_path)

    book = nil

    begin
      if COMPRESSED_FILE_EXTS.include?(File.extname(relative_path).downcase)
        data_from_compressed_file(real_path)
        return
      elsif ORDINARY_FILE_EXTS.include?(File.extname(relative_path).downcase)
        book = data_from_ordinary_file(real_path)
      end
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(Stories::Application.instance).send(:log_error, e)
      return
    end
    
    if book[:content].present?
      title = book[:title].gsub(/_/, ' ')
      Story.create!(:title => title, :content => book[:content], :published_on => last_modified, :sort_key => Story.sort_key(title))
    end

    #FileUtils.rm(real_path) if File.exists?(real_path)
  end

  def self.data_from_compressed_file(real_path)
    temp_dir = "#{Dir.tmpdir}/stories_#{SecureRandom.hex(10)}"
    Dir.mkdir(temp_dir)

    if File.extname(real_path).downcase == '.zip'
      system("unzip #{File.escape_name(real_path)} -d #{File.escape_name(temp_dir)}")
      import_directory(temp_dir)
      FileUtils.rm_rf(temp_dir)
    end
    #elsif RAR_EXTS.include?(File.extname(real_path))
    #  system("cd #{File.escape_name(destination_dir)} && unrar e #{File.escape_name(real_path)}")
    #end
  end
  
  def self.data_from_ordinary_file(real_path)
    text = File.read(real_path)
    is_html = HTML_EXTS.include?(File.extname(real_path).downcase) || text.include?("<html>") || text.include?("<HTML>")
    
    { :title => File.basename(real_path), :content => import_text(text, is_html ? "html" : "text") }
  end

  def self.import_text(text, format)
    text = text.to_ascii_iconv
    #encoding = %w(ISO-8859 iso-8859 windows-125 Windows-125).detect { |e| text.include?(e) } ? 'iso-8859-1' : 'utf-8'
    #text = Iconv.conv('utf-8//TRANSLIT', encoding, text)
    
    Nsf::Document.from(text, format).to_nsf
  end

  private
  def update_stats
    self.word_count = content.split(/\s+/).length
    self.byte_size = content.bytesize
  end
end


=begin
def normalize(element)
  element.children.map! do |child|
    if [:xml_comment, :xml_pi, :comment, :raw].include?(child.type)
      normalize(child)
      child.children
    elsif child.type == :html_element
      if child.value == 'br'
        start_index = element.children.index(child)
        i = start_index + 1
        while i < element.children.length
          current = element.children[i]

          next if current.type == :text && current.value.blank?
          if current.type == :html_element && current.value == 'br'
            start_index.upto(i) { |v| elements.children[v] = nil }
            break
          elsif !(current.type == :text && current.value.blank?)
            break
          end
          i += 1
        end

        child.type = :blank
        child.value = ""
        child.options[:category] = :block
        
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
=end