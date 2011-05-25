class FutureFile
  attr_accessor :filename, :content

  def initialize(filename = nil, content = nil)
    self.filename = filename
    self.content = content    
  end
end