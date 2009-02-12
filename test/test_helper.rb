require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.dirname(__FILE__))

class Test::Unit::TestCase
  def pid_running(pid)
    `ps -p #{pid.to_i.to_s} -o pid=`.size > 0
  end
end
