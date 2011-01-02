class String
  def to_ascii_iconv
    out = nil
    begin
      out = Iconv.conv('ASCII//IGNORE//TRANSLIT', 'UTF-8', self)
    rescue Exception => e
      out = self.dup
    end
    out.unpack('U*').select { |cp| cp < 127 }.pack('U*')
  end
end