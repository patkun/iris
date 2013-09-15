# -*- coding: utf-8 -*-

require 'pandoc-ruby'

class Iris

  def initialize(input)
    @input = input
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
    local_settings[0][:to] = "html5"
    converter = PandocRuby.new(@input,
                                *local_settings
                                ) # add handout.css
    return converter.convert
  end

  def markdown
    local_settings = @settings.dup
    local_settings[0][:to] = "markdown_strict"
    converter = PandocRuby.new(@input,
                                *local_settings
                                ) # add handout.css
    return converter.convert
  end

  def latex(layout=nil)
    local_settings = @settings.dup
    local_settings[0][:to] = "latex"
    local_settings << {:V => "twoside"}

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
      local_settings << {:V => "fontsize=12pt"}
    end

    converter = PandocRuby.new(@input,*local_settings)
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
