require "bundler/capistrano"
require './config/boot'

load 'deploy/assets'

set :application, 'bothunter'
set :repository,  "git@github.com:myhotspot/bothunter.git"

set :stages, ['production', 'staging']
set :default_stage, "production"

set :deploy_to, "/var/www/bothunter"
set :deploy_via, :remote_cache
set :branch, 'timothy'
set :scm, :git
set :scm_verbose, true
set :use_sudo, false
set :db_name_prefix, application.downcase.gsub(/[^a-z]/, '-')
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"
set :resque_pid, "#{deploy_to}/shared/pids/resque.pid"
set :unicorn_script, "/etc/init.d/bothunter"

set :keep_releases, 5

require 'capistrano/ext/multistage'

default_run_options[:pty] = true
ssh_options[:paranoid] = false
ssh_options[:user] = "deploy"
ssh_options[:forward_agent] = true
ssh_options[:port] = 2122

namespace :deploy do
  task :migrate do
    run "cd #{release_path} && bundle exec rake RAILS_ENV=production db:migrate --trace"
  end
  #task :restart do
  # run "/etc/init.d/bothunter restart"
  #end

  desc "Force restart"
  task :restart do
    run "sudo restart bothunter"
  end
  
  namespace :unicorn do
    desc "Remove unicron pid file"
    task :cleanup do
      run "rm #{unicorn_pid}"
    end
  end

  #desc "Kill all resque workers"

  desc "Make symlinks"
  task :symlink_configs do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/oauth_credentials.yml #{release_path}/config/oauth_credentials.yml"
    run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
    run "ln -nfs #{shared_path}/private #{release_path}/public/private"
    run "rm -rf #{release_path}/tmp/pids"
  end
  
  task :create_shared_dirs do
    run <<-CMD
mkdir #{shared_path}/config;
mkdir #{shared_path}/db;
CMD
    #mkdir #{shared_path}/.bundle;
  end
  
  task :create_log_files do
    run "touch #{shared_path}/log/development.log #{shared_path}/log/production.log #{shared_path}/log/test.log"
  end
end

namespace :logs do
  task :watch do
    stream("tail -f #{shared_path}/log/production.log")
  end
end

after "deploy:update_code", "deploy:symlink_configs"
after "deploy:symlink_configs", "deploy:migrate"
load 'deploy/assets'
#after "deploy:setup", "deploy:create_shared_dirs"
after "deploy:setup", "deploy:create_log_files"

#after "deploy:setup", "deploy:stop_resque"
#after "deploy:setup", "deploy:force_restart_through_upstart"
#after "deploy:setup", "bothunter:workers"% 