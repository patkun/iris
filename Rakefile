# -*- coding: utf-8 -*-
require 'rake/testtask'

task :default => :test



Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/ts_*.rb']
end

task :build do
  `(cd lib/iris; tt bubo_grammar.treetop)`
end

task :install do
  binfilepath = File.join("bin","iris")
  testbinfile = File.read(binfilepath)
  installbinfile = testbinfile.gsub(/^test=true$/,"test=false")
  File.open(binfilepath, 'w') {|f| f.write(installbinfile) }
  system("gem build iris.gemspec")
  system("gem install iris-0.1.gem")
  File.open(binfilepath, 'w') {|f| f.write(testbinfile) }
end


