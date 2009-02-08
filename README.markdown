# Active Listener: Event listening and firing system for ruby

## Description
This gem allows you to define tasks that can be run at specific time intervals. In the future, we plan to allow event listening and firing.

## Installation

### Latest Stable

    sudo gem install ngauthier-active-listener

### Cutting Edge

    git clone git@github.com:ngauthier/active-listener.git active-listener
    cd active-listener
    rake gem install

## Configuration

### Add a config file
In your rails project, add a config file like this:


    ---
      tasks:
        - task: my:rake:task
          period: 5


This instructs active-listener to run "rake my:rake:task" every 5 seconds.

Usually, these config files go in RAILS_ROOT/config/active-listener.yml.

### Include an initializer
Create a file in the initializers directory, like RAILS_ROOT/config/initializers/active-listener.rb that has this in it:

    require 'active-listener'
    ActiveListener.autostart(
      :config => File.join(RAILS_ROOT, 'config', 'active-listener.yml'),
      :log_file => File.join(RAILS_ROOT, 'log', 'active-listener-'+RAILS_ENV+'.log'),
      :pid_file => File.join(RAILS_ROOT, 'log', 'active-listener-'+RAILS_ENV+'.pid'),
      :rake_root => File.join(RAILS_ROOT)
    )

This will use the config file "config/active-listener.yml". It will put the log file in "log/active-listener.log" and the pid file for tracking the process in "log/active-listener.pid".

### Special Handling of ActiveListener rake tasks that depend on the rails environment
The scheme devised in the previous sections will generate infinite an infinite loop if your Active Listener rake tasks depend on the rails environment being loaded.  This occurs because we have added the initializer code into config/initializers.  In order to avoid this, we can set a global variable that is queried in the initializer, providing conditional load behavior.  Now, our initializer looks like this:

    if !$active_listener_activated
      require 'active-listener'
      ActiveListener.autostart(
        :config => File.join(RAILS_ROOT, 'config', 'active-listener.yml'),
        :log_file => File.join(RAILS_ROOT, 'log', 'active-listener-'+RAILS_ENV+'.log'),
        :pid_file => File.join(RAILS_ROOT, 'log', 'active-listener-'+RAILS_ENV+'.pid'),
        :rake_root => File.join(RAILS_ROOT)
      )
    end
    
And our Active Listener rake task (found in lib/tasks/active-listener.rake) looks like:

    desc "Helper to preclude infinite loop when a listener task depends on the rails environment"
    task :set_active_listener_active do
      $active_listener_activated = true
    end

    namespace :listeners do
      desc "Close games that have ended"
      task :game_end => [:set_active_listener_active, :environment] do
        # Logic as dictated by your app's needs
      end
    end

## Usage

Active Listener will automatically start whenever the rails environment is loaded. It will replace an existing instance of active-listener if the pid file is the same and there is one running.

So, you don't need to run the executable, it will "autostart" thanks to the initializer. Keep in mind this means that it will be running during your tests, development server, production, and any other environments you have. If you run your tests, the daemon keeps going after the tests are done. It doesn't stop when the server stops.

If you run your tests and you run the app in dev mode, there will be two instances running simultaneously and they'll both be running the tasks (but in the appropriate environment).

If you want to stop active-listener, run:

    active-listener --stop log/active-listener.pid

Make sure to point it to your pid file.


## Other notes
This gem uses Jeweler.

