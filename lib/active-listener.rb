require 'fileutils'
require 'yaml'

# =ActiveListener
# Set up an activelistener config file in your config directory describing the
# tasks #ActiveListener should execute. Then, in an initializer, run 
# #ActiveListener.autostart
class ActiveListener
  # All the #Events that an #ActiveListener is firing
  attr_reader :events

  # Run #autostart in an initializer to run #ActiveListener when your
  # Rails application initializes.
  #
  #  ActiveListener.autostart(
  #    :config => File.join(RAILS_ROOT, 'config', 'active-listener.yml'),
  #    :pid_file => File.join(RAILS_ROOT, 'log', 'active-listener-'+RAILS_ENV+'.pid'),
  #    :log_file => File.join(RAILS_ROOT, 'log', 'active-listener-'+RAILS_ENV+'.log'),
  #    :rake_root => RAILS_ROOT
  #  )
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
      "#{rake_root}",
    ].join(" ")
    `#{command}`
  end

  # Stop an #ActiveListener by specifying a pid file
  #
  #  ActiveListener.stop(:pid_file => File.join(RAILS_ROOT, 'log', 'active-listener.pid'))
  def self.stop(opts = {})
    pid_file = opts[:pid_file]
    `start-stop-daemon --stop --oknodo --pidfile #{File.expand_path(pid_file)}`
  end

  # Create an #ActiveListener in the foreground. This is useful for a non-rails project.
  #
  #  ActiveListener.new(
  #    :log_file => File.join('log', 'active-listener.log'),
  #    :rake_root => '.'
  #  )
  def initialize(opts = {})
    self.events = []
    self.log_file = opts[:log_file]
    self.rake_root = opts[:rake_root]
    clear_log
    log("ActiveListener Initialized")
    load_config(opts[:config])
  end

  # Add an event to event listener.
  #
  #  @al.add_event(Event.new(:task => 'my_task', :period => '10'))
  def add_event(evt)
    self.events.push(evt)
    log("Added Event #{evt.inspect}")
  end

  # Fire any events that have passed their period
  #
  #  @al.fire_events
  #
  # This will only fire events that have not been run within their period time of their last run
  def fire_events
    self.events.select{|e| e.time_to_fire < 0}.each do |evt|
      log("Firing event: #{evt.inspect}")
      log(evt.fire(:rake_root => rake_root))
    end
    self.events.sort{|x,y| x.time_to_fire <=> y.time_to_fire}
  end

  # Returns the time in seconds until the next event needs to be fired. Useful for sleeping
  # 
  #  sleep(@al.time_to_next_event)
  #  @al.fire_events
  def time_to_next_event
    if self.events.first
      sleep_time = self.events.first.time_to_fire+0.01
    else
      sleep_time = 0.5
    end
    return sleep_time
  end

  # Not functional yet.
  def self.trigger(port, event)

  end

  # An individual #ActiveListener #Event
  class Event
    # Create a new #Event
    #
    #  Event.new(
    #    :task => 'my:rake:task',
    #    :period => 50
    #  )
    def initialize(opts = {})
      self.task = opts[:task] || opts["task"]
      self.period = opts[:period] || opts["period"]
      self.trigger = opts[:trigger] || opts["trigger"]
      self.last_fire = Time.now.to_f
    end

    # The amount of time until this event will need to be fired
    def time_to_fire
      if period
        return last_fire + period - Time.now.to_f
      else
        # oh does! forever!
        return 1.0/0.0
      end
    end

    # Fire the event. I.e. run the rake task
    def fire(opts = {})
      self.last_fire = Time.now.to_f
      Dir.chdir(opts[:rake_root]) if opts[:rake_root]
      begin
        `RAILS_ENV=#{RAILS_ENV} rake #{task}`
      rescue
        `rake #{task}`
      end
    end

    # Manual firing trigger (not implemented)
    attr_reader :trigger
    # The amount of time in seconds between firing this task
    attr_reader :period
    # The last time this event was fired
    attr_reader :last_fire
    # A string representation of a rake task. "my:task"
    attr_reader :task

    private

    # Set the rake task
    attr_writer :task
    # Set the period
    attr_writer :period
    # Set the trigger
    attr_writer :trigger
    # Set last_fire time
    attr_writer :last_fire

  end

  private

  # Set the events this #ActiveListener has
  attr_writer :events
  # Log file path
  attr_accessor :log_file
  # Directory to run rake tasks from
  attr_accessor :rake_root
  # Port for triggers (not implemented)
  attr_accessor :port

  # Parse a config file to load up events.
  #
  #  @al.load_config('active-listener.yml')
  def load_config(config_file)
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
    port = yml["port"]
    # puts "The port: #{port}"
    if port
      self.port = port
      spawn_listener_thread
    end
  end

  # Delete the log file
  def clear_log
    return unless log_file
    FileUtils.rm_f log_file
  end
 
  # Log text to the log file
  def log(text)
    return unless log_file
    f = File.new(log_file, 'a')
    f.write "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]: #{text}"
    f.write "\n"
    f.close
  end

  # Trigger an event (not implemented)
  def trigger(trigger)
    self.events.select{|e| e.trigger == trigger}.each do |evt|
      log("Event triggered: #{evt.inspect}")
      log(evt.fire(:rake_root => rake_root))
    end
  end

  # Listen on a port for triggers (not implemented)
  def spawn_listener_thread
    # puts "Hey a port! #{port}"
  end

end
