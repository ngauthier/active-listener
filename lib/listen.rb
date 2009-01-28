#!/usr/bin/env ruby
require 'active_listener'

running = true
Signal.trap("TERM") do
  running = false
end

@al = ActiveListener.new
# Read events from YAML

while running
  @al.fire_events
  @al.sleep_to_next_event
end
