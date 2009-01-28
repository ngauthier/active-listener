require 'fileutils'

class ActiveListener
  attr_reader :events, :base_path

  def self.base_path
    begin
      base_path = File.join(RAILS_ROOT, 'activelistener', RAILS_ENV)
    rescue
      base_path = File.join('activelistener')
    end
    FileUtils.mkdir_p base_path
    base_path
  end

  def initialize(opts = {})
    self.events = []
    self.base_path = opts[:base_path] || ActiveListener.base_path
    load_events(opts[:config])
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

  class Event
    def initialize(opts = {})
      self.task = opts[:task] || opts["task"]
      self.period = opts[:period] || opts["period"]
      self.last_fire = 0
    end

    def time_to_fire
      last_fire + period - Time.now.to_f
    end

    def fire
      `rake #{task}`
      self.last_fire = Time.now.to_f
    end

    private

    attr_accessor :task, :period, :last_fire

  end

  private

  attr_writer :events, :base_path

  def load_events(config_file)
    return if config_file.nil?
    unless File.exists?(config_file)
      raise "Config file not found at #{File.expand_path(config_file)}" 
    end
    f = File.new(config_file,'r')
    yml = YAML.load(f)
    yml["tasks"].each do |task|
      self.add_event(Event.new(task))
    end
  end

end
