require 'fileutils'

class ActiveListener
  def initialize(opts = {})
    self.events = []
    self.base_path = opts[:base_path] || ActiveListener.base_path
  end

  def add_event(evt)
    self.events.push(evt)
  end

  def fire_events
    self.events.select{|e| e.time_to_fire < 0}.each do |evt|
      evt.fire
    end
  end

  def sleep_to_next_event
    self.events.sort{|x,y| x.time_to_fire <=> y.time_to_fire}
    if self.events.first
      sleep(self.events.first.time_to_fire+0.01)
    else
      sleep(0.5)
    end
  end

  def self.base_path
    begin
      base_path = File.join(RAILS_ROOT, 'activelistener', RAILS_ENV)
    rescue
      base_path = File.join('activelistener')
    end
    FileUtils.mkdir_p base_path
    base_path
  end

  attr_reader :events, :base_path

  class Event
    def initialize(opts = {})
      self.task = opts[:task]
      self.every = opts[:every]
      self.last_fire = 0
    end

    def time_to_fire
      last_fire + every - Time.now.to_f
    end

    def fire
      `rake #{task}`
      self.last_fire = Time.now.to_f
    end

    private
    attr_accessor :task, :every, :last_fire
  end

  private

  attr_writer :events, :base_path

end
