Gem::Specification.new do |s|
  s.name        = 'iris'
  s.version     = '0.1'
  s.executables << 'iris'
  s.date        = '2013-09-14'
  s.summary     = "A Pandoc Streamlining Library for Philological Texts."
  s.description = "**iris** helps produce beautiful printable texts for printing and in HTML for use in the Classics classroom."
  s.authors     = ["Patrick Kuntschnik"]
  s.email       = 'patrick.kuntschnik@gmail.com'
  s.files       = ["lib/iris.rb",
                   "lib/iris/bubo_grammar.rb",
                   "lib/iris/bubo_builder.rb",
                   "lib/iris/bubo_htmlhead.html",
                   "lib/iris/bubo_latexhead.tex",
                   "lib/iris/bubo_handout.css",
                   "lib/iris/bubo_i.js",
                   "lib/iris/default.latex",
                   "lib/iris/letter_template.tex"
                  ]
#  s.homepage    = 'http://rubygems.org/gems/iris'
  s.license       = 'MIT'
end
