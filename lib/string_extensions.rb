require 'iconv'

class String
  def to_utf8
    to_encoding('utf-8')
  end

  def to_ascii
    to_encoding('ascii')
  end

  def to_encoding(target_encoding)
    source_encoding = %w(ISO-8859 iso-8859 windows-125 Windows-125).detect { |e| self.include?(e) } ? 'windows-1252' : 'utf-8'
    already_tried = false

    begin
      return ::Iconv.conv("#{target_encoding}//TRANSLIT//IGNORE", source_encoding, self)
    rescue Exception => e
      unless already_tried
        #Try the other source encoding - we guessed wrong
        source_encoding = source_encoding == 'utf-8' ? 'iso-8859-1' : 'utf-8'
        already_tried = true
        retry
      end

      return self.dup
    end
  end
end
