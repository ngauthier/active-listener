require File.dirname(__FILE__) + '/test_helper'
require 'active_listener'

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
      @al.sleep_to_next_event
    end

    context "with a file timer" do
      setup do
        @al.add_event(
          ActiveListener::Event.new(
            :task => "test:touch_file",
            :period => 1
          )
        )
        FileUtils.rm_f(File.join('test','sample.txt'))
      end

      teardown do
        FileUtils.rm_f(File.join('test','sample.txt'))
      end

      should "touch a file" do
        assert !File.exists?(File.join('test','sample.txt'))
        @al.fire_events
        assert File.exists?(File.join('test','sample.txt'))
      end

      should "need to be fired when added" do
        assert @al.events[0].time_to_fire < 0
      end

      should "need to be fired 1 second after being fired" do
        @al.fire_events
        assert @al.events[0].time_to_fire > 0
        FileUtils.rm_f(File.join('test','sample.txt'))
        @al.fire_events
        assert !File.exists?(File.join('test','sample.txt'))
        @al.sleep_to_next_event
        assert @al.events[0].time_to_fire < 0
        assert !File.exists?(File.join('test','sample.txt'))
        @al.fire_events
        assert File.exists?(File.join('test','sample.txt'))
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
      @al.fire_events
      assert File.exists?(@sample_file)
    end

    should "fail if given a path to a nonexistant file" do
      assert_raise RuntimeError do
        @al = ActiveListener.new(:config => @config_path+'.fake')
      end
    end
  end

  context "An autostarted listener" do

    setup do
      ActiveListener.autostart(
        :config => File.join(File.dirname(__FILE__), 'active_listener.yml'),
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid')
      )
      @sample_file = File.join(File.dirname(__FILE__),'sample.txt')
    end

    teardown do
      ActiveListener.stop(
        :pid_file => File.join(File.dirname(__FILE__), 'active_listener.pid')
      )
      FileUtils.rm_f(@sample_file)
    end

    should "load events from the config file" do
      sleep(1)
      assert File.exists?(@sample_file)
      FileUtils.rm_f(@sample_file)
      assert !File.exists?(@sample_file)
      sleep(1)
      assert File.exists?(@sample_file)
    end

  end
end
