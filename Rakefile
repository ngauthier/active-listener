require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'
require 'lib/active-listener'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "active-listener"
    s.summary = %Q{TODO}
    s.email = "nick@smartlogicsolutions.com"
    s.homepage = "http://github.com/ngauthier/active-listener"
    s.description = "TODO"
    s.authors = ["Nick Gauthier"]
    s.executables = ['active-listener']
    s.files = FileList["[A-Z]*.*", "{bin,generators,lib,test,spec}/**/*"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end

namespace :test do
  desc "This is a task that will be called by the test suite to test the daemon"
  task :touch_file do
    f = File.new(File.join('test','sample.txt'),'w')
    f.write "ok"
    f.close
  end
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'active-listener'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rcov::RcovTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => :test
