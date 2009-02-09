require 'fileutils'
require 'yaml'

class ActiveListener
  attr_reader :events

  def self.autostart(opts = {})
    begin
      config_file = File.expand_path(opts[:config])
      pid_file    = File.expand_path(opts[:pid_file])
      log_file    = File.expand_path(opts[:log_file])
      rake_root   = File.expand_path(opts[:rake_root])
    rescue
      raise "Need :config :pid_file :log_file :rake_root"
    end
    command = [
      "start-stop-daemon --start",
      "--make-pidfile --pidfile #{pid_file}",
      "--background",
      "--startas #{File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin', 'active-listener'))}",
      "--chdir #{File.expand_path(File.dirname(__FILE__))}",
      "--",
      "#{config_file}",
      "#{log_file}",
      "#{rake_root}"
    ].join(" ")
    `#{command}`
  end

  def self.stop(opts = {})
    pid_file = opts[:pid_file]
    `start-stop-daemon --stop --oknodo --pidfile #{File.expand_path(pid_file)}`
  end

  def initialize(opts = {})
    self.events = []
    self.log_file = opts[:log_file]
    self.rake_root = opts[:rake_root]
    clear_log
    log("ActiveListener Initialized")
    load_events(opts[:config])
  end

  def add_event(evt)
    self.events.push(evt)
    log("Added Event #{evt.inspect}")
  end

  def fire_events
    self.events.select{|e| e.time_to_fire < 0}.each do |evt|
      log("Firing event: #{evt.inspect}")
      log(evt.fire(:rake_root => rake_root))
    end
    self.events.sort{|x,y| x.time_to_fire <=> y.time_to_fire}
  end

  def time_to_next_event
    if self.events.first
      sleep_time = self.events.first.time_to_fire+0.01
    else
      sleep_time = 0.5
    end
    return sleep_time
  end

  def sleep_to_next_event
    log("Sleeping for #{time_to_next_event}")
    sleep(time_to_next_event)
  end

  class Event
    def initialize(opts = {})
      self.task = opts[:task] || opts["task"]
      self.period = opts[:period] || opts["period"]
      self.last_fire = Time.now.to_f
    end

    def time_to_fire
      last_fire + period - Time.now.to_f
    end

    def fire(opts = {})
      self.last_fire = Time.now.to_f
      Dir.chdir(opts[:rake_root]) if opts[:rake_root]
      begin
        `RAILS_ENV=#{RAILS_ENV} rake #{task}`
      rescue
        `rake #{task}`
      end
    end

    private

    attr_accessor :task, :period, :last_fire

  end

  private

  attr_writer :events
  attr_accessor :log_file, :rake_root

  def load_events(config_file)
    return if config_file.nil?
    unless File.exists?(config_file)
      log("Config file not found at #{config_file}")
      return
    end
    log("Loading tasks from #{config_file}")
    f = File.new(config_file,'r')
    yml = YAML.load(f)
    yml["tasks"].each do |task|
      self.add_event(Event.new(task))
    end
  end

  def clear_log
    return unless log_file
    FileUtils.rm_f log_file
  end

  def log(text)
    return unless log_file
    f = File.new(log_file, 'a')
    f.write "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]: #{text}"
    f.write "\n"
    f.close
  end

end
