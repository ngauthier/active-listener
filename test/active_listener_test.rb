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
          :every => 5
        )
      )
      assert !@al.events.empty?
    end

    context "with a file timer" do
      setup do
        @al.add_event(
          ActiveListener::Event.new(
            :task => "test:touch_file",
            :every => 1
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
end
