#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#require 'pandoc-ruby'
handoutcss = "#{File.dirname(__FILE__)}/iris.d/handout.css"

mdfile = ARGV.last
pdffile = mdfile.gsub(/(md|txt|org|[a-z]+)$/,"pdf")
htmlfile = mdfile.gsub(/(md|txt|org|[a-z]+)$/,"html")
markdownfile = mdfile.gsub(/(md|txt|org|[a-z]+)$/,"plain.md")

t = IO.read(mdfile)

cmd = ARGV.shift

case cmd
when "html"
  IO.popen("pandoc --smart -o #{htmlfile} -f markdown+hard_line_breaks -t html5 --css #{handoutcss} --self-contained", 'r+') {|f| # don't forget 'r+'
    f.puts(t) # you can also use #write
    f.close_write
    f.read # get the data from the pipe
  }
  puts "Output written to #{htmlfile}"

when "md"
  IO.popen("pandoc --smart -o #{markdownfile} -f markdown+hard_line_breaks -t markdown_strict", 'r+') {|f| # don't forget 'r+'
    f.puts(t) # you can also use #write
    f.close_write
    f.read # get the data from the pipe
  }
  puts "Output written to #{markdownfile}"

when "pdf"
  layout = ARGV.shift
  case layout
  when "twocolumn"
    IO.popen("pandoc -o #{pdffile} -f markdown+hard_line_breaks --latex-engine=xelatex -V twoside -V twocolumn -V geometry=\"top=1.8cm\" -V geometry=\"bottom=1.8cm\" -V geometry=\"inner=1.8cm\" -V geometry=\"outer=1cm\" -V fontsize=11pt", 'r+') {|f| # don't forget 'r+'
      f.puts(t) # you can also use #write
      f.close_write
      f.read # get the data from the pipe
    }
  when "large"
    IO.popen("pandoc -o #{pdffile} -f markdown+hard_line_breaks --latex-engine=xelatex -V fontsize=14pt -V twoside -V geometry=\"top=1.8cm\" -V geometry=\"bottom=1.8cm\" -V geometry=\"inner=1.8cm\" -V geometry=\"outer=1cm\" -V documentclass=extarticle", 'r+') {|f| # don't forget 'r+'
      f.puts(t) # you can also use #write
      f.close_write
      f.read # get the data from the pipe
    }
  else
    IO.popen("pandoc -o #{pdffile} -f markdown+hard_line_breaks --latex-engine=xelatex -V fontsize=12pt -V twoside", 'r+') {|f| # don't forget 'r+'
      f.puts(t) # you can also use #write
      f.close_write
      f.read # get the data from the pipe
    }
  end
  puts "Output written to #{pdffile}"
end

class Iris

  def initialize(input)
    @input = input
  end

  def html
    @converter = PandocRuby.new(string, {:from => "markdown+hard_line_breaks".to_sym, :to => :html5}, :smart, :s) # add handout.css
    puts @converter.convert
  end

end
