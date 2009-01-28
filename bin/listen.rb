#!/usr/bin/env ruby
require 'active_listener'

running = true
Signal.trap("TERM") do
  running = false
end

@al = ActiveListener.new :config => ARGV[0]

raise "ActiveListener is very boring without events" if @al.events.empty?

while running
  @al.fire_events
  @al.sleep_to_next_event
end
