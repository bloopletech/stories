class FutureFile
  attr_reader :filename, :content, :mimetype

  def initialize(filename, content = nil, mimetype = nil)
    @filename = filename
    @content = content
    @mimetype = mimetype || Mime::Type.lookup_by_extension(File.extname(filename).downcase.tr('.',''))
  end
end
