#!/usr/bin/env ruby
Signal.trap("TERM") do
  puts "I am done"
  exit(0)
end
puts "let us listen"
while true
  sleep(5)
end
