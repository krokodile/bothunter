$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require 'bundler/capistrano'

set :stages, ['production']
set :default_stage, "production"

set :application, "bothunter"
set :repository,  "git@github.com:reflow/bothunter.git"

set :rvm_ruby_string, '1.9.3-rc1'
set :rvm_type, :system

set :deploy_to, "/www/rails/bothunter/"
set :deploy_via, :remote_cache
set :branch, 'master'
set :scm, :git
set :scm_verbose, true
set :use_sudo, false
set :delayed_job_params, "-n 20"
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
  desc "Force restart"
  task :force_restart_through_upstart do
    run %Q{
      sudo stop bothunter;
      rm /etc/init/bothunter*;
      cd #{current_path};
      foreman export upstart /etc/init -a bothunter -u deploy;
      sudo start bothunter;
    }
  end
  
  namespace :unicorn do
    desc "Remove unicron pid file"
    task :cleanup do
      run "rm #{unicorn_pid}"
    end
  end

  desc "Kill all resque workers"

  desc "Make symlinks"
  task :symlink_configs do
   # run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
    run "ln -nfs #{shared_path}/private #{release_path}/public/private"
    run "rm -rf #{release_path}/tmp/pids"
  end
  
  namespace :gems do
    desc "Install required gems"
    task :install do
      run <<-CMD
        cd #{latest_release};
        #{sudo} rake gems:install;
      CMD
    end
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

after "deploy:setup", "deploy:create_shared_dirs"
after "deploy:setup", "deploy:create_log_files"

after "deploy:setup", "deploy:stop_resque"
after "deploy:setup", "deploy:force_restart_through_upstart"

after "deploy:setup", "deploy:assets:clean"
after "deploy:setup", "deploy:assets:precompile"
after "deploy:setup", "deploy:assets:symlink"