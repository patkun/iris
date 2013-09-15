require_relative File.join("..","lib","iris.rb")
require "test/unit"

class TestIris < Test::Unit::TestCase

  def test_html
    s = File.read(File.join(File.dirname(__FILE__),"aux","sampletext.txt"))
    i = Iris.new(s)
    assert_respond_to(i,"html")
    assert_match(/h1/,i.html)
  end

  def test_markdown
    s = File.read(File.join(File.dirname(__FILE__),"aux","sampletext.txt"))
    i = Iris.new(s)
    assert_respond_to(i,"markdown")
    assert_match(/bit of text/,i.markdown)
  end

  def test_pdf
    s = File.read(File.join(File.dirname(__FILE__),"aux","sampletext.txt"))
    i = Iris.new(s)
    assert_respond_to(i,"latex")
    assert_match(/bit of text/,i.latex)
    assert_match(/twocolumn/,i.latex("twocolumn"))
    assert_match(/14pt/,i.latex("large"))
    #puts i.latex("large")
    assert_match(/inner=1.8cm/,i.latex("large"))
    assert_match(/12pt/,i.latex(nil))
    assert_respond_to(i,"pdf")
    i.pdf(nil,File.join(File.dirname(__FILE__),"aux"))
    assert(File.file?(File.join(File.dirname(__FILE__),"aux","texput.pdf")))
    File.delete(File.join(File.dirname(__FILE__),"aux","texput.pdf"))
  end

  def test_bubo
    s = File.read(File.join(File.dirname(__FILE__),"aux","sampletext.txt"))
    i = Iris.new(s,true)
    assert_respond_to(i,"latex")
    assert_match(/textbf/,i.latex)
    assert_respond_to(i,"html")
    assert_match(/bit of text/,i.html)
    puts i.html
  end

  def test_bin
    assert_match(/bit of text/,`ruby bin/iris html test/aux/sampletext.txt`)
    assert_match(/bit of text/,`ruby bin/iris latex test/aux/sampletext.txt`)
    system("ruby bin/iris pdf test/aux/sampletext.txt")
    assert(File.file?(File.join(File.dirname(__FILE__),"aux","texput.pdf")))
    File.delete(File.join(File.dirname(__FILE__),"aux","texput.pdf"))
    assert_match(/inner=1.8cm/,`ruby bin/iris latex large test/aux/sampletext.txt`)
  end

end
