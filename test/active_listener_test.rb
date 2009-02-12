require File.dirname(__FILE__) + '/test_helper'
require 'active-listener'

class ActiveListenerTest < Test::Unit::TestCase
  context "A new listener" do

    setup do
      @al = ActiveListener.new({})
    end

    should "have an empty events list" do
      assert @al.events.empty?
    end

    should "be able to add an event" do
      @al.add_event(
        ActiveListener::Event.new(
          :task => "meh", 
          :period => 5
        )
      )
      assert !@al.events.empty?
    end

    should "sleep when it has no events" do
      sleep(@al.time_to_next_event)
    end

    context "with a file timer" do
      setup do
        @al.add_event(
          ActiveListener::Event.new(
            :task => "test:touch_file",
            :period => 1
          )
        )
        @sample_file = File.join(File.dirname(__FILE__),'sample.txt')
        FileUtils.rm_f(@sample_file)
      end

      teardown do
        FileUtils.rm_f(File.join(File.dirname(__FILE__),'sample.txt'))
      end

      should "touch a file" do
        assert !File.exists?(@sample_file)
        sleep(@al.time_to_next_event)
        @al.fire_events
        assert File.exists?(@sample_file)
      end

      should "not need to be fired when added" do
        assert @al.events[0].time_to_fire > 0
      end

      should "need to be fired 1 second after being fired" do
        @al.fire_events
        assert @al.events[0].time_to_fire > 0
        FileUtils.rm_f(@sample_file)
        @al.fire_events
        assert !File.exists?(@sample_file)
        sleep(@al.time_to_next_event)
        assert @al.events[0].time_to_fire < 0
        assert !File.exists?(@sample_file)
        @al.fire_events
        assert File.exists?(@sample_file)
        assert @al.events[0].time_to_fire > 0
      end

    end
  end

  context "A listener" do
    setup do
      @config_path = File.join(File.dirname(__FILE__), 'active_listener.yml')
      @sample_file = File.join(File.dirname(__FILE__),'sample.txt')
      FileUtils.rm_f @sample_file
    end

    should "be able to read events from yaml" do
      @al = ActiveListener.new(:config => @config_path)
      assert @al.events.size > 0
      assert !File.exists?(@sample_file)
      sleep(@al.time_to_next_event)
      @al.fire_events
      assert File.exists?(@sample_file)
    end

  end

  context "An autostarted listener" do

    setup do
      assert ActiveListener.autostart(
        :config => File.join(File.dirname(__FILE__), 'active_listener.yml'),
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid'),
        :log_file => File.join(File.dirname(__FILE__), 'active_listener.log'),
        :rake_root => File.join(File.dirname(__FILE__), '..')
      )
      @sample_file = File.join(File.dirname(__FILE__),'sample.txt')
    end

    teardown do
      ActiveListener.stop(
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid')
      )
      sleep(1)
      FileUtils.rm_f(File.join(File.dirname(__FILE__),'sample.txt'))
    end

    should "load events from the config file" do
      sleep(2)
      assert File.exists?(@sample_file)
      FileUtils.rm_f(@sample_file)
      assert !File.exists?(@sample_file)
      sleep(1)
      assert File.exists?(@sample_file)
      FileUtils.rm_f(@sample_file)
      assert !File.exists?(@sample_file)
      sleep(1)
      assert File.exists?(@sample_file)
    end

    should "not duplicate processes" do
      pf = File.new(File.join(File.dirname(__FILE__), 'active_listener.pid'))
      pid = pf.read
      pf.close
      assert(pid_running(pid))
      ActiveListener.autostart(
        :config => File.join(File.dirname(__FILE__), 'active_listener.yml'),
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid'),
        :log_file => File.join(File.dirname(__FILE__), 'active_listener.log'),
        :rake_root => File.join(File.dirname(__FILE__), '..')
      )
      pf = File.new(File.join(File.dirname(__FILE__), 'active_listener.pid'))
      new_pid = pf.read
      pf.close
      assert_equal pid, new_pid
      assert(pid_running(pid))
    end

    should "be able to be stopped and a new one can be run" do
      pf = File.new(File.join(File.dirname(__FILE__), 'active_listener.pid'))
      pid = pf.read
      pf.close
      assert(pid_running(pid))
      ActiveListener.stop(
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid')
      )
      sleep(1)
      assert(!pid_running(pid))
      ActiveListener.autostart(
        :config => File.join(File.dirname(__FILE__), 'active_listener.yml'),
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid'),
        :log_file => File.join(File.dirname(__FILE__), 'active_listener.log'),
        :rake_root => File.join(File.dirname(__FILE__), '..')
      )
      pf = File.new(File.join(File.dirname(__FILE__), 'active_listener.pid'))
      new_pid = pf.read
      pf.close
      assert_not_equal pid, new_pid
      assert(pid_running(new_pid))
      assert(!pid_running(pid))
    end
  end

  context "An event-based listener" do

    setup do
      @al = ActiveListener.new({})
      @al.add_event(ActiveListener::Event.new(
        :task => 'test:touch_file',
        :trigger => "MY_TRIGGER"
      ))
      @sample_file = File.join(File.dirname(__FILE__),'sample.txt')
      FileUtils.rm_f @sample_file
    end

    teardown do
      FileUtils.rm_f @sample_file
    end

    should "not fire any events at the beginning" do
      assert !File.exists?(@sample_file)
      assert @al.time_to_next_event.infinite?
      @al.fire_events
      assert !File.exists?(@sample_file)
    end
  end

  context "An auto-started event based listener" do
    setup do
      ActiveListener.stop(
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid')
      )
      sleep(0.5)
      ActiveListener.autostart(
        :config => File.join(File.dirname(__FILE__), 'active_listener-events.yml'),
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid'),
        :log_file => File.join(File.dirname(__FILE__), 'active_listener.log'),
        :rake_root => File.join(File.dirname(__FILE__), '..')
      )
      @sample_file = File.join(File.dirname(__FILE__),'sample.txt')
    end

    teardown do
      ActiveListener.stop(
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid')
      )
      sleep(1)
      FileUtils.rm_f(File.join(File.dirname(__FILE__),'sample.txt'))
    end

    should "be able to be triggered" do
      #assert !File.exists?(@sample_file)
      #ActiveListener.trigger(20150,"MY_TRIGGER")
      #assert File.exists?(@sample_file)
    end
  end
end
