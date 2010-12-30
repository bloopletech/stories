require 'cgi'
require 'active_support/all'

module Nsf
  class Document
    attr_accessor :nodes
    
    def initialize(nodes)
      @nodes = nodes
    end

    def self.from(text, format)
      self.send("from_#{format}", text)
    end

    def self.from_nsf(text)
      self.from_blocks(text.split("\n\n"))
    end

    def self.from_text(text)
      blocks = []

      in_paragraph = true
      current_text = ""
      prev_line = ""
      lines = text.split("\n")
      lines.each do |line|
        puts "line.blank? #{line.blank?}"
        puts "line == lines.last #{line == lines.last}"
        puts "current_text.present? #{current_text.present?}"
        puts "lsp(line) == 0 #{lsp(line) == 0}"
        puts "lsp(line) < lsp(prev_line) #{lsp(line) < lsp(prev_line)}"
        if line.blank? || line == lines.last || (current_text.present? && ((lsp(line) < lsp(prev_line))))
          if in_paragraph
            in_paragraph = false

            if current_text != ""
              blocks << current_text.gsub(/\s+/, ' ').strip
              current_text = ""
            end
          end
        elsif line =~ /^#+ /
          blocks << line
        else
          in_paragraph = true
          current_text << " " << line
          prev_line = line
        end
      end

      self.from_blocks(blocks)
    end

    def self.from_html(text)
      doc = Nokogiri::HTML(text)
      self.iterate(doc)
    end
    
    def self.iterate(node)
      puts "node.node_name: #{node.node_name}"
      node.children.each { |n| self.iterate n }
    end

    def self.normalize(element)
      element.children.map! do |child|
        if [:xml_comment, :xml_pi, :comment, :raw].include?(child.type)
          normalize(child)
          child.children
        elsif child.type == :html_element
          if child.value == 'br'
            child.type = :br
            child.value = ""
            child.options[:category] = :span
            
            child
          elsif child.value == 'div'
            child.value = 'p'
            child
          elsif child.value == 'p'
            child
          elsif child.children.empty?
            nil
          else
            normalize(child)
            child.children
          end
        else
          normalize(child)
          child
        end
      end
      element.children.flatten!
      element.children.compact!
    end

    def self.from_blocks(blocks)
      self.new(blocks.map do |block|
        if block =~ /^#+ /
          Heading.new(block)
        elsif block =~ /^    /
          Fixedblock.from_nsf(block)
        else
          Paragraph.new(block)
        end
      end)
    end
  
    # LSP == Leading SPaces
    def self.lsp(str)
      str =~ /^(\s+)/
      $1 ? $1.length : 0
    end

    def to_nsf
      nodes.map(&:to_nsf).join("\n\n")
    end

    def to_html
      nodes.map(&:to_html).join
    end
  end
     
  class Paragraph
    attr_accessor :text

    def initialize(text)
      @text = text
    end

    def to_nsf
      @text
    end

    def to_html
      #in_bold = false
      #in_italic = false

      out = @text
      out = out.gsub(/(\A\*| \*)(.*?)(\*\Z|\* )/, "<b>\\2</b>") #Need to rethink
      
      "<p>#{out}</p>"
    end
  end

  class Fixedblock < Paragraph
    
    def to_html
      "<pre>#{CGI.escapeHTML(text.gsub(/^    /, ''))}</pre>"
    end
  end

  class Heading
    attr_accessor :text, :level

    def initialize(text)
      text =~ /^(#+) (.*?)$/
      @text = $2
      @level = $1.length
    end

    def to_nsf
      "#{"#" * level} #{text}"
    end
    
    def to_html
      "<h#{level}>#{CGI.escapeHTML(text)}</h#{level}>"
    end
  end
end