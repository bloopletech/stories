class File
  BAD_CHARACTER_REGEX = /([ \[\]\(\)'"&!\\])/
  
  def self.escape_name(filename)
    filename.gsub(BAD_CHARACTER_REGEX) { |r| "\\#{$1}" }
  end

  def self.sanitize_name(filename)
    filename.gsub('/', '_').gsub(/[[:space:]]+/, ' ').gsub(BAD_CHARACTER_REGEX, "_")
  end
end