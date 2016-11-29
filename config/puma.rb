puts "RUBY_PLATFORM:\t#{RUBY_PLATFORM}"
puts "------------------------------" 
if RUBY_PLATFORM !~ /mingw/
  puts "workers:\t#{Integer(ENV['WEB_CONCURRENCY'] || 2)}"
  workers Integer(ENV['WEB_CONCURRENCY'] || 2)
end

puts "threads_count:\t#{Integer(ENV['MAX_THREADS'] || 5)}"
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

before_fork do
  PumaWorkerKiller.config do |config|
    config.ram           = Integer(ENV['RAM'] || 1024) # mb (size of ram on standard-2x heroku dyno)
    config.frequency     = 3600    # evaluate every hour
    config.percent_usage = 0.98
    config.rolling_restart_frequency = Integer(ENV['ROLLING_RESTART_FREQUENCY_HOURS'] || 3) * 3600 # 3 hours in seconds
    config.reaper_status_logs = true # setting this to false will not log lines like:
    # PumaWorkerKiller: Consuming 54.34765625 mb with master and 2 workers.
  end
  PumaWorkerKiller.start
end

on_worker_boot do
  # Valid on Rails 4.1+ using the `config/database.yml` method of setting `pool` size
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
