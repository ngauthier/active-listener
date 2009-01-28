#!/usr/bin/env ruby
require 'active_listener'

running = true
Signal.trap("TERM") do
  running = false
end

@al = ActiveListener.new :config => ARGV[0], :log => ARGV[1]

if @al.events.empty?
  log = File.new(ARGV[1], 'a')
  log.write "ActiveListener is very boring without events"
  log.close
  running = false
end

while running
  @al.fire_events
  @al.sleep_to_next_event
end
