class ActiveListener
  def initialize(opts = {})
    self.events = []
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
    sleep(self.events[0].time_to_fire)
  end
  attr_reader :events

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

  attr_writer :events

end
