# -*- coding: utf-8 -*-

require 'pandoc-ruby'
require 'treetop'
require_relative 'iris/bubo_grammar'
require_relative 'iris/bubo_builder'

class Iris
  attr_accessor :bubo

  def initialize(input,bubo=false)
    @bubo = bubo
    @input = input
    @tree = nil
    if bubo then
      buboparser = BuboGrammarParser.new
      @tree = buboparser.parse(@input)
    end
    @settings = [
                 {
                   :from => "markdown+hard_line_breaks",
                   :to => "markdown",
                 },
                 :smart,
                 :s
                ]
  end

  def html
    local_settings = @settings.dup
    local_input = @input.dup
    unless @tree.nil? then
      local_input = @tree.munch("html")
      preamblepath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_htmlhead.html")
      preamble = File.read(preamblepath)
      jspath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_i.js")
      preamble.gsub!(/bubo_i.js/,jspath)
      csspath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_handout.css")
      preamble.gsub!(/bubo_handout.css/,csspath)
      local_settings << {:V => "header-includes='#{preamble}'"}
    end
    local_settings[0][:to] = "html5"
    local_settings << "self-contained"
    converter = PandocRuby.new(local_input,
                                *local_settings
                                ) # add handout.css
    return converter.convert
  end

  def markdown
    local_settings = @settings.dup
    local_input = @input.dup
    unless @tree.nil? then
      local_input = @tree.munch("markdown_strict")
    end
    local_settings[0][:to] = "markdown_strict"
    converter = PandocRuby.new(local_input,
                                *local_settings
                                ) # add handout.css
    return converter.convert
  end

  def latex(layout=nil)
    local_settings = @settings.dup
    local_input = @input.dup
    unless @tree.nil? then
      local_input = @tree.munch("latex")
      preamblepath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_latexhead.tex")
      preamble = File.read(preamblepath)
      local_settings << {:V => "header-includes=\"#{preamble}\""}
    end

    local_settings[0][:to] = "latex"
    local_settings << {:V => "twoside"}
    local_settings << {:V => "geometry=a4paper"}
    local_settings << {"latex-engine" => "xelatex"}

    case layout

    when "twocolumn"
      local_settings << {:V => "geometry=top=1.8cm"}
      local_settings << {:V => "geometry=bottom=1.8cm"}
      local_settings << {:V => "geometry=inner=1.8cm"}
      local_settings << {:V => "geometry=outer=1cm"}
      local_settings << {:V => "twocolumn"}
      local_settings << {:V => "fontsize=11pt"}

    when "large"
      local_settings << {:V => "geometry=top=1.8cm"}
      local_settings << {:V => "geometry=bottom=1.8cm"}
      local_settings << {:V => "geometry=inner=1.8cm"}
      local_settings << {:V => "geometry=outer=1cm"}
      local_settings << {:V => "fontsize=14pt"}
      local_settings << {:V => "documentclass=extarticle"}

    else
      if @tree.nil? then
        local_settings << {:V => "fontsize=12pt"}
      end

    end

    converter = PandocRuby.new(local_input,*local_settings)
    return converter.convert

  end

  def pdf(layout=nil,outputdir=nil)
    options = Array.new
    if outputdir then options << "--output-directory=\"#{outputdir}\"" end
    path = [outputdir,"texput.pdf"].delete_if{|i| i.nil?}
    texputpdf = File.join(*path)
    path.last.gsub!(/pdf$/,"*")
    texputfiles = Dir.glob(File.join(*path))
    IO.popen("xelatex #{options.join(' ')}".chomp, 'r+') {|f| # don't forget 'r+'
      f.puts(self.latex(layout)) # you can also use #write
      f.close_write
      f.read # get the data from the pipe
    }

  end

end
