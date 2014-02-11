require 'pandoc-ruby'

module Vocab
  @list = Array.new

  def self.add(x)
    @list << x
  end

  def self.list
    return @list
  end

  def self.flush
    @list = Array.new
  end
end

module Nota
  @list = Array.new

  def self.add(x)
    @list << x
  end

  def self.list
    return @list
  end

  def self.flush
    @list = Array.new
  end
end

module Document

  def munch(f)
    t = String.new
    elements.each {|element|
      t << element.munch(f)
    }
    t
  end
  def getenv(e,f)
    t = Array.new
    elements.each {|element|
      if element.extension_modules.include? Environment
        element.elements.each {|envelement|
          if envelement.extension_modules.include? Envoperation
            if envelement.text_value == e
              element.elements.each {|envelement|
                if envelement.extension_modules.include? Environmentcontent
                  t << envelement.munch(f).gsub!(/^<p>(.*)<\/p>$/m,'\1')
                end
              }
            end
            break
          end
        }
      end
    }
    t
  end
  def getcom(c,p,f)
    t = Array.new
    elements.each {|element|
      if element.extension_modules.include? Command
        element.elements.each {|comelement|
          if comelement.extension_modules.include? Operation
            if comelement.text_value == c
              element.elements.each {|comelement|
                if comelement.extension_modules.include? Parameters
                  t << comelement.get(f)[p].gsub!(/^<p>(.*)<\/p>$/m,'\1')
                end
              }
            end
            break
          end
        }
      end
    }
    t
  end
end

module Environment
  def munch(f)
    case envoperation.text_value
    when "commentary"
      if f.format == "latex"
        return self.desc(f)
      else
        return ""
      end
    when "settext"
      if f.format == "latex"
        return self.desc(f)
      else
        return environmentcontent.munch(f)
      end
    when "gr"
      if f.format == "latex"
        return self.desc(f)
      elsif f.format == "html"
        return "<span class=\"greek\">" + environmentcontent.munch(f) + "</span>"
      else
        return environmentcontent.munch(f)
      end
    when "la"
      if f.format == "latex"
        return self.desc(f)
      elsif f.format == "html"
        return "<span class=\"latin\">" + environmentcontent.munch(f) + "</span>"
      else
        return environmentcontent.munch(f)
      end
    when "pupiltext"
      if f.version == "pupiltext"
        return environmentcontent.munch(f)
      else
        return ""
      end
    when "teachertext"
      if f.version == "teachertext"
        return environmentcontent.munch(f)
      else
        return ""
      end
    else
      return environmentcontent.munch(f)
    end
  end
  def desc(f)
    t = "\\begin{" + envoperation.text_value + "}" + environmentcontent.munch(f) + "\\end{" + envoperation.text_value + "}"
    return t
  end
end

module Environmentcontent
    def munch(f)
      t = ""
      self.elements.each {|element|
        t << element.munch(f)
      }
      @converter = PandocRuby.new(t, {:from => 'markdown+hard_line_breaks+pipe_tables', :to => f.format.to_sym}, 'no-wrap')
      t = @converter.convert
      t.strip
  end
end

module Command
  def munch(f)
    case operation.text_value
    when "agree"
      agree_tag = parameters.get(f)[0].gsub!(/^<p>(.*)<\/p>$/m,'\1')
      if f.format == "html"
        agree_arr = agree_tag.gsub(/-/,' ').split
        agree_arr.map!{|c|
          if c =~ /^[0-9]+$/ then "cong#{c}" else c end
        }
        return "<span class=\"agree #{agree_arr.uniq.join(" ")}\">" + parameters.get(f)[1].gsub!(/^<p>(.*)<\/p>$/m,'\1') + "</span>"
      else
        return parameters.get(f)[1]
      end
    when "nota"
      nota = parameters.get(f)[0].gsub!(/^<p>(.*)<\/p>$/m,'\1')
      intext = parameters.get(f)[1].gsub!(/^<p>(.*)<\/p>$/m,'\1')
      if f.format == "latex"
        return self.desc(f)
      elsif f.format == "html"
        Nota.add(nota)
        o = "<span class=\"nota_anchor nota#{Nota.list.length - 1}\">" + intext + "</span>"
        return o
      else
        return parameters.get(f)[1]
      end
    when "vocab"
      lemma = parameters.get(f)[0].gsub!(/^<p>(.*)<\/p>$/m,'\1')
      intext = parameters.get(f)[1].gsub!(/^<p>(.*)<\/p>$/m,'\1')
      if f.format == "latex"
        #return self.desc(f)
        return parameters.get(f)[1]
      elsif f.format == "html"
        Vocab.add(lemma)
        o = "<span class=\"vocab_anchor vocab#{Vocab.list.length - 1}\">" + intext + "</span>"
        return o
      else
        return parameters.get(f)[1]
      end
    when "gr"
      if f.format == "latex"
        return self.desc(f)
      elsif f.format == "html"
        return "<span class=\"greek\">" + parameters.get(f)[0].gsub!(/^<p>(.*)<\/p>$/m,'\1') + "</span>"
      else
        return parameters.getval[1]
      end
    when "la"
      if f.format == "latex"
        return self.desc(f)
      elsif f.format == "html"
        return "<span class=\"latin\">" + parameters.get(f)[0].gsub!(/^<p>(.*)<\/p>$/m,'\1') + "</span>"
      else
        return parameters.getval[1]
      end
    else
      return self.desc(f)      
    end
  end
  def desc(f)
    o = ""
    unless options.empty?
      o = options.text_value
    end
    return "\\" + operation.text_value + o + parameters.munch(f)
  end
end

module Simplecommand
  def munch(f)
    o = ""
    unless options.empty?
      o = options.text_value
    end
    return self.text_value
  end
end

module Parameters
  def munch(f)
    t = ""
    self.elements.each {|element|
      t << element.munch(f)
    }
    t
  end
  def get(f)
    parray = []
    parray += self.elements.collect { |para| para.elements[1].munch(f) }
    parray
  end
  def getval()
    parray = []
    parray += self.elements.collect { |para| para.elements[1].text_value }
    parray
  end
end

module Parameter
  def munch(f)
    t = ""
    self.elements.each {|element|
      t << element.munch(f)
    }
    t
  end
end

module Parametercontent
    def munch(f)
    t = ""
    self.elements.each {|element|
      t << element.munch(f)
    }
      @converter = PandocRuby.new(t, {:from => 'markdown+hard_line_breaks+pipe_tables', :to => f.format.to_sym}, 'no-wrap')
    t = @converter.convert
    t.strip
  end
end

module Text
  def munch(f)
    return text_value
  end
end

module Brace
  def munch(f)
    return text_value
  end
end

module Operation
  def munch(f)
    return text_value
  end
end

module Envoperation
  def munch(f)
    return text_value
  end
end

module Comment
  def munch(f)
    return ''
  end
end
