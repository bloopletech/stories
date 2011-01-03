class String
  def to_utf8
    encoding = %w(ISO-8859 iso-8859 windows-125 Windows-125).detect { |e| self.include?(e) } ? 'iso-8859-1' : 'utf-8'
    already_tried = false
    
    begin
      return Iconv.conv('utf-8//TRANSLIT//IGNORE', encoding, self)
    rescue Exception => e
      unless already_tried
        #Try the other source encoding - we guessed wrong
        encoding = encoding == 'utf-8' ? 'iso-8859-1' : 'utf-8'
        already_tried = true
        retry
      end
      
      return self.dup
    end
  end
end