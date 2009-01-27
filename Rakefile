require 'rake'
require 'rake/testtask'

namespace :listener do
  desc "Start the listener"
  task :start do
    listener = File.expand_path(File.join('lib', 'listen.rb'))
    command = [
      "start-stop-daemon --start",
      "--pidfile listen.pid --make-pidfile",
      "--background",
      "--exec #{listener}"
    ].join(" ")
    system(command)
  end

  desc "Stop the listener"
  task :stop do
    listener = File.expand_path(File.join('lib', 'listen.rb'))
    system("start-stop-daemon --stop --pidfile listen.pid ")
    FileUtils.rm_f("listen.pid")
  end
end

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
