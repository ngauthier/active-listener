require 'rake'
require 'rake/testtask'
require 'lib/active_listener'

namespace :listener do
  desc "Start the listener"
  task :start => [:paths, :stop] do
    command = [
      "start-stop-daemon --start",
      "--make-pidfile --pidfile #{LISTEN_PID}",
      "--background",
      "--exec #{LISTEN_BIN}",
      "--chdir #{LIB_PATH}"
    ].join(" ")
    puts command
    system(command)
  end

  desc "Stop the listener"
  task :stop => [:paths] do
    system("start-stop-daemon --stop --pidfile #{LISTEN_PID}")
    FileUtils.rm_f(LISTEN_PID)
  end

  desc "Sets up paths for ActiveListener"
  task :paths do
    BASE_PATH  = File.expand_path(ActiveListener.base_path)
    LISTEN_BIN = File.expand_path(File.join('lib','listen.rb'))
    LISTEN_PID = File.expand_path(File.join(BASE_PATH, 'activelistener.pid'))
    LIB_PATH = File.expand_path('lib')
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
