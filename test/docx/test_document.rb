require 'docx'
require 'test/unit'

class DocxTest < Test::Unit::TestCase
  def setup
    @doc = Docx::Document.open('test/fixtures/basic.docx')
  end
  
  def test_basic_functionality
    assert_equal 2, @doc.paragraphs.size
    assert_equal 'hello', @doc.paragraphs.first.text
    assert_equal 'world', @doc.paragraphs.last.text
    assert_equal "hello\nworld", @doc.text
  end
  
  def test_each_paragraph
    @doc.each_paragraph do |p|
      assert_kind_of Docx::Containers::Paragraph, p
      assert p.text_runs.all? { |r| r.formatting == default_formatting }
    end
  end
  
  def test_each_text_run
    @doc.each_paragraph do |p|
      p.each_text_run do |tr|
        assert_kind_of Docx::Containers::TextRun, tr
      end
    end
  end
  
  private
  
  def default_formatting
    Docx::Containers::TextRun::DEFAULT_FORMATTING
  end
end
