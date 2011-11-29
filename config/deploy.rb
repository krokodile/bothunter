$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require 'rvm/capistrano' # Для работы rvm
#require 'bundler/capistrano'
load 'deploy/assets'

set :stages, %w(production)
set :default_stage, "staging"


set :application, "voipman"
role :web, "wayfi.ru"                          
role :app, "wayfi.ru"
set :port, 2122
set :repository,  "git@github.com:reflow/voipman.git"
set :deploy_to, "/var/rails/voipman"
set :deploy_via, :remote_cache
set :branch, 'master'
set :scm, :git
set :scm_verbose, true
set :use_sudo, false
set :rvm_ruby_string, '1.9.2' # Это указание на то, какой Ruby интерпретатор мы будем использовать.
set :rvm_type, :profile # Указывает на то, что мы будем использовать rvm, установленный у пользователя, от которого происходит деплой, а не системный rvm.
set :unicorn_script, "/etc/init.d/voipman"


# require multistage. must be here! 
#require 'capistrano/ext/multistage'

default_run_options[:pty] = true
ssh_options[:profile] = "deploy"
ssh_options[:forward_agent] = true


namespace :deploy do  
  task :bundle do
    run "cd #{deploy_to}/current/ && bundle install"
  end


 task :restart do
  run "/etc/init.d/voipman restart"
 end


end

  after :deploy, "deploy:bundle"
  after :deploy, "deploy:restart"

