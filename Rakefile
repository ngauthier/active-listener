require 'rake'
require 'rake/testtask'
require 'lib/active_listener'

namespace :test do
  desc "This is a task that will be called by the test suite to test the program"
  task :touch_file do
    f = File.new(File.join('test','sample.txt'),'w')
    f.write "ok"
    f.close
  end
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end

task :default => :test
