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
        - task: my:other:rake:task
          period: 14


This instructs active-listener to run "rake my:rake:task" every 5 seconds and "rake my:other:rake:task" every 14 seconds.

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

## Usage

Active Listener will automatically start whenever the rails environment is loaded. It will not start if there is one already running with the pid in the pid file.

So, you don't need to run the executable, it will "autostart" thanks to the initializer. Keep in mind this means that it will be running during your tests, development server, production, and any other environments you have. If you run your tests, the daemon keeps going after the tests are done. It doesn't stop when the server stops.

If you run your tests and you run the app in dev mode, there will be two instances running simultaneously and they'll both be running the tasks (but in the appropriate environment).

If you want to stop active-listener, run:

    active-listener --stop log/active-listener.pid

## Other notes
This gem uses Jeweler.

