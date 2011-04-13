class Story < ActiveRecord::Base
  acts_as_taggable

  validates_presence_of :title, :content

  before_save :update_autos, :if => lambda { |story| story.content_changed? }
  
  def nsf
    Nsf::Document.from_nsf(content)
  end

  def open
    increment!(:opens)
    update_attribute(:last_opened_at, DateTime.now)
  end

  def self.sort_key(title)
    title.gsub(/[^A-Za-z0-9]+/, '').downcase
  end

  COMPRESSED_FILE_EXTS = %w(.zip)
  HTML_EXTS = %w(.htm .html)
  NSF_EXTS = %w(.txt)
  ORDINARY_FILE_EXTS = HTML_EXTS + NSF_EXTS
  VALID_EXTS = COMPRESSED_FILE_EXTS + ORDINARY_FILE_EXTS #Add rtf later

  #Iterate recursively over all files/dirs
  #If current item is a zip/rar/cbr/cbz file, pull out first image and store zip filename as manga name and zip filename as filename to load.
  #Else if current item is a dir, and it contains images but no directories, store the dir name as the manga name as well as the load filename.
  #Else skip/recurse into dir.
  #Do not call more than once at a time
  def self.import
    import_directory(Stories.import_dir)
    system("cd #{File.escape_name(Stories.import_dir)} && find . -depth -type d -empty -exec rmdir {} \\;")
  end
  
  def self.import_directory(dir)
    require 'fileutils'
    FileUtils.rm_rf(Dir.glob("#{File.escape_name(dir)}/**/*_files"))
    
    #Requires GNU find 3.8 or above
    cmd = <<-CMD
cd #{File.escape_name(dir)} && find . \\( -type f \\( #{VALID_EXTS.map { |ext| "-iname '*#{ext}'" }.join(' -o ')} \\) \\)
CMD

    $stdout.puts #This makes it actually import; fuck knows why

    path_list = IO.popen(cmd) { |s| s.read }
    path_list = path_list.split("\n").map { |e| e.gsub(/^\.\//, '') }.reject { |e| e[0, 1] == '.' }

    path_list.each { |path| self.import_file("#{dir}/#{path}") }
  end

  def self.import_file(real_path)
    last_modified = File.mtime(real_path)

    book = nil

    begin
      if COMPRESSED_FILE_EXTS.include?(File.extname(real_path).downcase)
        data_from_compressed_file(real_path)
        return
      elsif ORDINARY_FILE_EXTS.include?(File.extname(real_path).downcase)
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

    FileUtils.rm(real_path) if File.exists?(real_path)
  end

  def self.data_from_compressed_file(real_path)
    temp_dir = "#{Dir.tmpdir}/stories_#{SecureRandom.hex(10)}"
    Dir.mkdir(temp_dir)

    if File.extname(real_path).downcase == '.zip'
      system("unzip #{File.escape_name(real_path)} -d #{File.escape_name(temp_dir)}")
      import_directory(temp_dir)
      FileUtils.rm(real_path) if File.exists?(real_path)
    end
    #elsif RAR_EXTS.include?(File.extname(real_path))
    #  system("cd #{File.escape_name(destination_dir)} && unrar e #{File.escape_name(real_path)}")
    #end

    FileUtils.rm_rf(temp_dir)
  end
  
  def self.data_from_ordinary_file(real_path)
    text = File.read(real_path).to_utf8
    is_html = HTML_EXTS.include?(File.extname(real_path).downcase) || text.downcase.include?("<html>")
    
    doc = Nsf::Document.from(text, is_html ? "html" : "text")
    
    { :title => (doc.title || File.basename(real_path) || "Unknown title"), :content => doc.to_nsf }
  end

  STOPWORDS = File.read("#{Rails.root}/config/stopwords.txt").split("\n")

  def self.wfa(text, exclusion_text)
    exclusions = exclusion_text.split(/\s/).map { |e| wfa_preprocess(e) }

    hash = Hash.new(1)
    text.split(/\s/).each { |w| hash[wfa_preprocess(w)] += 1 }
    hash.reject! { |k, v| STOPWORDS.include?(k.downcase) || exclusions.include?(k.downcase) || k.blank? }
    hash.to_a.sort_by { |(k, v)| v }.reverse.map { |(k, v)| k }[0..7]
  end

  private
  def self.wfa_preprocess(text)
    text.to_ascii.gsub(/^[^A-z]+/, '').gsub(/[^A-z]+$/, '').gsub(/'[Ss]$/, '')
  end

  def update_autos
    self.word_count = content.split(/\s+/).length
    self.byte_size = content.bytesize
    self.most_frequent_words = Story.wfa(self.content, self.title).join(" ")
  end

  public
  def export(format)
    send("export_#{format}")
  end

  def export_html
    File.open("#{Stories.export_dir}/#{File.sanitize_name(title)}_#{id}.html", "w") do |f|
      f << <<-EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>#{CGI.escapeHTML title}</title>
  </head>
  <body>
    #{nsf.to_html}
  </body>
</html>
EOF
      f.flush
    end
  end

  def export_text
    File.open("#{Stories.export_dir}/#{File.sanitize_name(title)}_#{id}.txt", "w") do |f|
      f << nsf.to_nsf
      f.flush
    end
  end

  def export_rtf
    File.open("#{Stories.export_dir}/#{File.sanitize_name(title)}_#{id}.rtf", "w") do |f|
      f << nsf.to_rtf
      f.flush
    end
  end
end