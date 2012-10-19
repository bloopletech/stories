#These functions are generally bash (or bash like) specific
class File
  FORBIDDEN_CHARACTER_REGEX = /([:\"+<>\*\?\|\[\]\/\\[:cntrl:]])/
  GLOB_CHARACTER_REGEX = /([\*\{\}\[\]\?\\])/

  #Bash specific! 
  def self.quote_name(filename)
    "'" + filename.gsub("'", "'\\''") + "'"
  end

  def self.sanitize_name(filename)
    filename.gsub(FORBIDDEN_CHARACTER_REGEX, "_")
  end

  def self.quote_glob_name(filename)
    filename.gsub(GLOB_CHARACTER_REGEX) { |r| "\\#{$1}" }
  end
end
