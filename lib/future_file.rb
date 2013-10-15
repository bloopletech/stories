class FutureFile
  attr_reader :filename, :content, :mtime, :mimetype

  def initialize(filename, content = nil, mtime = nil, mimetype = nil)
    @filename = filename
    @content = content
    @mtime = Time.at(mtime.to_time.to_i)
    @mimetype = mimetype || Mime::Type.lookup_by_extension(File.extname(filename).downcase.tr('.',''))
  end
end
