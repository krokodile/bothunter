#$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
#require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require 'bundler/capistrano'
#require 'flowdock/capistrano'

# for Flowdock Gem notifications
set :flowdock_project_name, "sCRM"
set :flowdock_deploy_tags, ["unicorn", "rvm system-wide"]
set :flowdock_api_token, "9b4cbe213a88a3cc8cb5585a7dc3b8bf"

set :default_environment, {
  'PATH' => "/usr/local/rvm/bin:/usr/local/rvm/gems/ruby-1.9.3-p0/bin:/usr/local/rvm/rubies/ruby-1.9.3-p0/bin:$PATH",
  'RUBY_VERSION' => 'ruby 1.9.3-p0',
  'GEM_HOME'     => '/usr/local/rvm/gems/ruby-1.9.3-p0',
  'GEM_PATH'     => '/usr/local/rvm/gems/ruby-1.9.3-p0',
  'BUNDLE_PATH'  => '/usr/local/rvm/gems/ruby-1.9.3-p0'  # If you are using bundler.
}

set :stages, ['production']
set :default_stage, "production"

set :application, 'scrm.myhotspot.ru:8080'
set :repository,  "git@github.com:reflow/bothunter.git"

#set :rvm_ruby_string, '1.9.3-p0'
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
  #task :restart do
  #  run "/etc/init.d/bothunter restart"
  #end

  desc "Force restart"
  task :force_restart_through_upstart do
=begin
    run %Q{
      sudo stop bothunter;
      rm /etc/init/bothunter*;
      cd #{current_path};
      foreman export upstart /etc/init -a bothunter -u deploy;
      sudo start bothunter;
    }
=end
    run "/etc/init.d/bothunter stop && /etc/init.d/bothunter start"
    #run "service bothunter-workers stop && service bothunter-workers start"
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
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
    run "ln -nfs #{shared_path}/config/credentials.yml #{release_path}/config/credentials.yml"
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
    run "ln -nfs #{shared_path}/private #{release_path}/public/private"
    run "rm -rf #{release_path}/tmp/pids"
  end
  
=begin
  namespace :gems do
    desc "Install required gems"
    task :install do
      run "cd #{current_path} && bundle install"
    end
  end
=end
  
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

#  desc "Notify flow about deployment using email"
##  task :notify_flow do
#    # create a new Flow object with target flow's api token and sender information
#    flow = Flowdock::Flow.new(:api_token => "_YOUR_API_TOKEN_HERE_",
#      :source => "Capistrano deployment", :project => "My project",
#      :from => {:name => "John Doe", :address => "john.doe@yourdomain.com"})
#
#    # send message to the flow
#    flow.send_message(:format => "html", :subject => "Application deployed #deploy",
#      :content => "Application deployed successfully!", :tags => ["deploy", "frontend"])
#  end
end



namespace :logs do
  task :watch do
    stream("tail -f #{shared_path}/log/production.log")
  end
end

after "deploy:update_code", "deploy:symlink_configs"

after "deploy:setup", "deploy:create_shared_dirs"
after "deploy:setup", "deploy:create_log_files"

#after "deploy:setup", "deploy:stop_resque"
after "deploy:setup", "deploy:force_restart_through_upstart"

after "deploy:setup", "deploy:assets:clean"
after "deploy:setup", "deploy:assets:precompile"
after "deploy:setup", "deploy:assets:symlink"
#after "deploy:setup", "bothunter:workers"