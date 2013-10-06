# -*- coding: utf-8 -*-

require 'pandoc-ruby'
require 'treetop'
require 'json'
require_relative 'iris/bubo_grammar'
require_relative 'iris/bubo_builder'

class Iris
  attr_accessor :bubo, :tree

  def initialize(input,bubo=false)
    @bubo = bubo
    @input = input
    @tree = nil
    @buboparser = nil
    if bubo then
      @buboparser = BuboGrammarParser.new
      @tree = @buboparser.parse(@input)
    end
    @settings = [
                 {
                   :from => "markdown+hard_line_breaks",
                   :to => "markdown",
                 },
                 :smart,
                 :s,
                 "no-wrap".to_sym
                ]
  end

  def html
    local_settings = @settings.dup
    local_input = @input.dup
    Vocab.flush
    Nota.flush
    unless @tree.nil? then
      local_input = @tree.munch("html")
      preamblepath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_htmlhead.html")
      preamble = File.read(preamblepath)
      jspath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_i.js")
      preamble.gsub!(/bubo_i.js/,jspath)
      preamble.gsub!(/vocab = null/,"vocab = #{Vocab.list.to_json}")
      preamble.gsub!(/nota = null/,"nota = #{Nota.list.to_json}")
      csspath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_handout.css")
      local_settings << {:V => "css='#{csspath}'"}
      #preamble.gsub!(/bubo_handout.css/,csspath)
      local_settings << {:V => "header-includes='#{preamble}'"}
      local_input << "<div id=\"info_bar\"><div id=\"vocab_box\">foo</div><div id=\"nota_box\">foo</div></div>"
    end
    local_settings[0][:to] = "html5"
    local_settings << "self-contained"
    converter = PandocRuby.new(local_input,
                                *local_settings
                                )
    o = converter.convert

    # DIRTY PROCESSING
    o.gsub!(/<br \/><\/li>/){|m| "</li>"}

    return o
  end

  def markdown
    local_settings = @settings.dup
    local_input = @input.dup
    Vocab.flush
    Nota.flush
    unless @tree.nil? then
      local_input = @tree.munch("markdown_strict")
    end
    local_settings[0][:to] = "markdown_strict"
    converter = PandocRuby.new(local_input,
                                *local_settings
                                )
    return converter.convert
  end

  def latex(layout=nil,pretty=false)
    local_settings = @settings.dup
    local_input = @input.dup
    Vocab.flush
    Nota.flush
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
    if pretty == true then
      local_settings << {:V => "pretty"}
    end

    case layout

    when "twocolumn"
      local_settings << {:V => "geometry=top=1.8cm"}
      local_settings << {:V => "geometry=bottom=1.8cm"}
      local_settings << {:V => "geometry=inner=1.8cm"}
      local_settings << {:V => "geometry=outer=1cm"}
      local_settings << {:V => "twocolumn"}
      local_settings << {:V => "fontsize=11pt"}

    when "large"
      local_settings << {:V => "geometry=top=2cm"}
      local_settings << {:V => "geometry=bottom=2cm"}
      local_settings << {:V => "geometry=inner=2cm"}
      local_settings << {:V => "geometry=outer=2cm"}
      local_settings << {:V => "fontsize=14pt"}
      local_settings << {:V => "documentclass=extarticle"}

    when "margins"
      local_settings << {:V => "geometry=top=3cm"}
      local_settings << {:V => "geometry=bottom=3cm"}
      local_settings << {:V => "geometry=inner=5cm"}
      local_settings << {:V => "geometry=outer=6cm"}
      local_settings << {:V => "fontsize=11pt"}

    else
      if @tree.nil? then
        local_settings << {:V => "fontsize=12pt"}
      end

    end

    # DIRTY PROCESSING
    local_input.gsub!(/([A-Z]{2,}( [A-Z]{2,})*)/){|m| "\\textsc{#{$1.downcase}}"}


    converter = PandocRuby.new(local_input,*local_settings)
    o = converter.convert

    # MORE DIRTY PROCESSING
    o.gsub!(/\\itemsep1pt/,"\\itemsep0pt")
    o.gsub!(/\\begin{enumerate}.*?\\end{enumerate}/m){|m| m.gsub(/\\\\$/,"")}
    o.gsub!(/\\begin{itemize}.*?\\end{itemize}/m){|m| m.gsub(/\\\\$/,"")}
    o.gsub!(/\\begin{description}.*?\\end{description}/m){|m| m.gsub(/\\\\$/,"")}
    return o

  end

  def pdf(layout=nil,pretty=false,test=false)
    options = Array.new
    texputpdf = "texput.pdf"
    if test then
      outputdir=File.expand_path('../test/aux', File.dirname(__FILE__))
      options << "--output-directory=\"#{outputdir}\""
      texputpdf = File.join(outputdir,"texput.pdf")
    end
    texputfiles = Dir.glob(texputpdf.gsub(/pdf$/,"*"))
    IO.popen("xelatex #{options.join(' ')}".chomp, 'r+') {|f| # don't forget 'r+'
      f.puts(self.latex(layout,pretty)) # you can also use #write
      f.close_write
      f.read # get the data from the pipe
    }

  end

  def vocab
    return Vocab.list
  end

end
