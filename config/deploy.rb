set :application, 'qridithomewatch'

set :scm, :git
set :repo_url, 'git@bitbucket.org:divinedesignsca/qridit-homewatch-edition.git'
set :branch, 'old_server_master'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/qridithomewatch'

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml config/settings/staging.yml config/settings/production.yml config/weather.yml config/production.sphinx.conf}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system db/sphinx public/support/screenshots}

set :normalize_assets_timestamps, %w{public/images public/javascript public/stylesheets}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :db do
  desc 'Seed the database on already deployed code'
  task seed: ['rvm:hook'] do
    on roles(:db), in: :sequence, wait: 5 do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:seed'
        end
      end
    end
  end
end

# namespace :resque do
#   desc 'Start worker'
#   task work: ['rvm:hook'] do
#     on roles(:app), in: :sequence, wait: 5 do
#       within release_path do
#         with rails_env: fetch(:rails_env), pidfile: './tmp/pids/resque.pid', background: 'yes', queue: '*' do
#           execute :rake, 'resque:work'
#         end
#       end
#     end
#   end
# end

namespace :unicorn do
  desc 'Restart app server'
  task restart: ['rvm:hook'] do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        sudo '/etc/init.d/unicorn', 'restart'
      end
    end
  end
end

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      sudo '/etc/init.d/unicorn', 'restart'
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
      sudo '/etc/init.d/memcached', 'restart'
    end
  end

  after :restart, 'thinking_sphinx:rebuild'
  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end
