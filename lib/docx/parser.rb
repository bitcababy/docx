require 'docx/containers'
require 'nokogiri'
require 'zip/zip'

module Docx
  class Parser
    def initialize(path)
      @zip = Zip::ZipFile.open(path)
      @xml = Nokogiri::XML(@zip.find_entry('word/document.xml').get_input_stream)
      
      if block_given?
        yield self
        @zip.close
      end
    end
    
    def paragraphs
      @xml.xpath('//w:document//w:body//w:p').map { |p_node| parse_paragraph_from p_node }
    end
    
    private
    
    def parse_paragraph_from(p_node)
      Containers::Paragraph.new(parse_runs_from(p_node))
    end
    
    def parse_runs_from(p_node)
      p_node.xpath('w:r').map do |r_node|
        rpr_node = r_node.xpath('w:rPr')
        Containers::TextRun.new({
          text:       parse_text_from(r_node),
          formatting: parse_formatting_from(rpr_node)
        })
      end
    end
    
    def parse_text_from(r_node)
      r_node.xpath('w:t').map(&:text).join('')
    end
    
    def parse_formatting_from(rpr_node)
      {
        italic:    !rpr_node.xpath('w:i').empty?,
        bold:      !rpr_node.xpath('w:b').empty?,
        underline: !rpr_node.xpath('w:u').empty?
      }
    end
  end
end
