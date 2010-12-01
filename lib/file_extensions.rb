class File
  def self.escape_name(filename)
    filename.gsub(/([ \[\]\(\)'"&!\\])/) { |r| "\\#{$1}" }
  end
end