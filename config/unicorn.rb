# # Sample verbose configuration file for Unicorn (not Rack)
# #
# # This configuration file documents many features of Unicorn
# # that may not be needed for some applications. See
# # http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# # for a much simpler configuration file.
# #
# # See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# # documentation.

# APP_ROOT = '/var/www/qridithomewatch/current'

# # user 'unprivileged_user', 'unprivileged_group'

# worker_processes 6

# working_directory APP_ROOT

# listen "#{APP_ROOT}/tmp/sockets/unicorn.sock", backlog: 64

# timeout 30

# pid "#{APP_ROOT}/tmp/pids/unicorn.pid"

# stderr_path "#{APP_ROOT}/log/unicorn_stderr.log"
# stdout_path "#{APP_ROOT}/log/unicorn_stdout.log"

# preload_app true

# GC.respond_to?(:copy_on_write_friendly=) and
#     GC.copy_on_write_friendly = true

# check_client_connection false

# before_fork do |server, worker|
#   defined?(ActiveRecord::Base) and
#       ActiveRecord::Base.connection.disconnect!
# end

# after_fork do |server, worker|
#   defined?(ActiveRecord::Base) and
#       ActiveRecord::Base.establish_connection
# end
# Heroku config
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end