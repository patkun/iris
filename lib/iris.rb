# -*- coding: utf-8 -*-

require 'pandoc-ruby'
require 'treetop'
require 'json'
require 'yaml'
require_relative 'iris/bubo_grammar'
require_relative 'iris/bubo_builder'

class Iris
  attr_accessor :bubo, :tree, :font, :inputfile, :standalone, :landscape, :settings

  def initialize(input,bubo=false,pandoc_opts=false)
    @bubo = bubo
    @input = input
    @org = false
    @inputfile = nil
    @comments = false
    @tree = nil
    @landscape = false
    @linestretch = nil
    @tree_f = OpenStruct.new
    @tree_f.version = "pupiltext"
    @buboparser = nil
    if bubo then
      @buboparser = BuboGrammarParser.new
      @tree = @buboparser.parse(@input)
    end
    @font = "neohellenic"
    @standalone = false
    @settings = [
      {
        :from => "markdown+hard_line_breaks+pipe_tables",
        :to => "markdown"
      },
      'no-wrap',
      :smart,
      :s
    ]
    if not pandoc_opts.empty? then
      @settings << pandoc_opts
    end
  end

  def inputfile(inputfile)
    @inputfile = inputfile
    if @inputfile =~ /\.org$/ then
      @settings[0][:from] = "org+hard_line_breaks+pipe_tables"
    end
  end

  def comments(comments)
    @comments = comments
    if @comments == true then
      @input.gsub!(/<!-{2,3}/,"").gsub!(/-->/,"")
    end
  end

  def org(org)
    @org = org
    if @org == true then
      @input.gsub!(/(?<!\n)\n(?!\n)/,"\n\\\\\\")
      @settings[0][:from] = "org+hard_line_breaks+pipe_tables"
    end
  end

  def version(version)
    @tree_f.version = version
  end

  def font(font)
    @font = font
  end

  def linestretch(linestretch)
    @linestretch = linestretch
  end

  def landscape(landscape)
    @landscape = landscape
  end

  def standalone(standalone)
    @standalone = standalone
  end

  def letter(*p)
    local_input = @input.dup
    local_settings = @settings.dup
    local_settings.delete(:s)
    local_settings[0][:to] = "latex"
    o = File.read(File.join(File.dirname(File.expand_path(__FILE__)), "iris","letter_template.tex"))
    frontmatter = YAML.load(local_input)
    address = frontmatter["address"].chomp.gsub(/\n/,"\\\\\\\\\\\\\\\\")
    opening = frontmatter["opening"]
    closing = frontmatter["closing"]
    subject = frontmatter["subject"]
    signature = frontmatter["signature"]
    local_input.gsub!(/---(.|\n)*---/,"")
    o.sub!(/ADDRESS/,"#{address}")
    o.sub!(/OPENING/,"#{opening}")
    o.sub!(/CLOSING/,"#{closing}")
    o.sub!(/SUBJECT/,"#{subject}")
    o.sub!(/SIGNATURE/,"#{signature}")
    converter = PandocRuby.new(local_input,*local_settings)
    o.sub!(/TEXT/,"#{converter.convert}")
    puts o
  end

  def html(*p)
    local_settings = @settings.dup
    local_input = @input.dup
    Vocab.flush
    Nota.flush
    unless @tree.nil? then
      @tree_f.format = "html"
      local_input = @tree.munch(@tree_f)
      #### uncomment to get back interactive html
      #preamblepath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_htmlhead.html")
      #preamble = File.read(preamblepath)
      #jspath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_i.js")
      #preamble.gsub!(/bubo_i.js/,jspath)
      #preamble.gsub!(/vocab = null/,"vocab = #{Vocab.list.to_json}")
      #preamble.gsub!(/nota = null/,"nota = #{Nota.list.to_json}")
      #csspath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_handout.css")
      #local_settings << :s
      #local_settings << {:V => "css='#{csspath}'"}
      ###preamble.gsub!(/bubo_handout.css/,csspath)
      #local_settings << {:V => "header-includes='#{preamble}'"}
      #local_settings << "self-contained"
      #local_input << "<div id=\"info_bar\"><div id=\"vocab_box\">foo</div><div id=\"nota_box\">foo</div></div>"
    end
    unless @font.nil? then
      local_settings << {:V => @font}
    end
    local_settings[0][:to] = "html5"
    if @standalone then
    #local_settings << "self-contained"
    else
      local_settings.delete(:s)
    end
    converter = PandocRuby.new(local_input,
                               *local_settings
                              )
    o = converter.convert

    # DIRTY PROCESSING
    o.gsub!(/<br \/><\/li>/){|m| "</li>"}

    return o
  end

  def markdown(*p)
    local_settings = @settings.dup
    local_input = @input.dup
    Vocab.flush
    Nota.flush
    unless @tree.nil? then
      @tree_f.format = "markdown_strict"
      local_input = @tree.munch(@tree_f)
    end
    local_settings[0][:to] = "markdown_strict"
    converter = PandocRuby.new(local_input,
                               *local_settings
                              )
    return converter.convert
  end

  def latex(layout=nil,raw=nil,size="11pt")
    local_settings = @settings.dup
    local_input = @input.dup
    Vocab.flush
    Nota.flush
    unless @tree.nil? then
      @tree_f.format = "latex"
      local_input = @tree.munch(@tree_f)
      preamblepath = File.join(File.dirname(File.expand_path(__FILE__)), "iris","bubo_latexhead.tex")
      preamble = File.read(preamblepath)
      local_settings << {:V => "header-includes=\"#{preamble}\""}
    end

    local_settings[0][:to] = "latex"
    local_settings << {:V => "twoside"}
    local_settings << {:V => "tables"}
    local_settings << {:V => "geometry=a4paper"}
    if @landscape then
      local_settings << {:V => "geometry=landscape"}
    end
    if @linestretch then
      local_settings << {:V => "linestretch=#{@linestretch}"}
    end
    local_settings << {"latex-engine" => "xelatex"}
    local_settings << :biblatex
    unless @font.nil? then
      local_settings << {:V => @font}
    end

    case layout

    when "twocolumn"
      local_settings << {:V => "geometry=top=1.8cm"}
      local_settings << {:V => "geometry=bottom=1.8cm"}
      local_settings << {:V => "geometry=inner=1.8cm"}
      local_settings << {:V => "geometry=outer=1cm"}
      local_settings << {:V => "twocolumn"}

    when "sheet"
      local_settings << {:V => "geometry=top=2cm"}
      local_settings << {:V => "geometry=bottom=2cm"}
      local_settings << {:V => "geometry=inner=2cm"}
      local_settings << {:V => "geometry=outer=2cm"}

    when "margins"
      local_settings << {:V => "geometry=top=3cm"}
      local_settings << {:V => "geometry=bottom=3cm"}
      local_settings << {:V => "geometry=inner=5cm"}
      local_settings << {:V => "geometry=outer=6cm"}

    when "nomargins"
      local_settings << {:V => "geometry=top=1cm"}
      local_settings << {:V => "geometry=bottom=1cm"}
      local_settings << {:V => "geometry=inner=2cm"}
      local_settings << {:V => "geometry=outer=1cm"}
      local_settings << {:V => "geometry=footskip=0.5cm"}

    end

    if not size.nil? then
      local_settings << {:V => "fontsize=#{size}"}
      unless size == "10pt" or size == "11pt" or size == "12pt" then
        local_settings << {:V => "documentclass=extarticle"}
      end
    else
      local_settings << {:V => "fontsize=11pt"}
    end

    # DIRTY PROCESSING
    #local_input.gsub!(/([A-Z]{2,}( [A-Z]{2,})*)/){|m| "\\textsc{#{$1.downcase}}"}
    o = String.new

    if raw.nil? then
      converter = PandocRuby.new(local_input,*local_settings)
      o = converter.convert
    else
      converter = PandocRuby.new("--REPLACEME--",*local_settings)
      o = converter.convert
      o = o.gsub(/--REPLACEME--/,local_input.gsub(/\\\\/,"\\\\\\\\\\\\\\\\"))
    end

    # MORE DIRTY PROCESSING
    o.gsub!(/\\itemsep1pt/,"\\itemsep0pt")
    o.gsub!(/\\begin{enumerate}.*?\\end{enumerate}/m){|m| m.gsub(/\\\\$/,"")}
    o.gsub!(/\\begin{itemize}.*?\\end{itemize}/m){|m| m.gsub(/\\\\$/,"")}
    o.gsub!(/\\begin{description}.*?\\end{description}/m){|m| m.gsub(/\\\\$/,"")}
    return o

  end

  def pdf(layout=nil,test=false,size)
    options = Array.new
    texputpdf = "texput.pdf"
    if test then
      outputdir=File.expand_path('../test/aux', File.dirname(__FILE__))
      options << "--output-directory=\"#{outputdir}\""
      texputpdf = File.join(outputdir,"texput.pdf")
    end
    texputfiles = Dir.glob(texputpdf.gsub(/pdf$/,"*"))
    IO.popen("xelatex #{options.join(' ')}".chomp, 'r+') {|f| # don't forget 'r+'
      f.puts(self.latex(layout,nil,size)) # you can also use #write
      f.close_write
      f.read # get the data from the pipe
    }

  end

  def rawlatex(*p)
    local_input = @input.dup
    unless @tree.nil? then
      @tree_f.format = "latex"
      local_input = @tree.munch(@tree_f)
    end
    o = local_input
    return o
  end

  def mrkd(*p)
    local_input = @input.dup
    local_input.gsub!(/--\+--/,'--|--')
    o = local_input
    return o
  end

  def vocab(*p)
    return Vocab.list
  end

end
