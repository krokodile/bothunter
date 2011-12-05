#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'resque/tasks'
require 'resque_scheduler/tasks'

BotHunter::Application.load_tasks


task "resque:setup" => :environment
task "resque:scheduler_setup" => :environment

desc "Start a parse workers"
task 'bothunter:workers' => :environment do
  Rake::Task["resque:setup"].reenable
  Rake::Task["resque:setup"].invoke

  Rake::Task["resque:work"].reenable
  Rake::Task["resque:work"].invoke
end

desc "Start a parse scheduler"
task 'bothunter:scheduler' => :environment do
  Rake::Task["resque:setup"].reenable
  Rake::Task["resque:setup"].invoke

  Rake::Task["resque:scheduler"].reenable
  Rake::Task["resque:scheduler"].invoke
end

namespace :scrm do
  desc "kill all workers (using -QUIT), god will take care of them"
  task :stop_workers => :environment do
    pids = []

    Resque.workers.each do |worker|
      pids << worker.to_s.split(/:/).second
    end

    if pids.size > 0
      system("kill -QUIT #{pids.join(' ')}")
    end
  end

  desc "Force restart"
  task :force_restart_through_upstart do
    Rake::Task["bothunter:stop_workers"].reenable
    Rake::Task["bothunter:stop_workers"].invoke

    system %Q{
      sudo stop bothunter;
      rm /etc/init/bothunter*;
      cd #{Rails.root};
      foreman export upstart /etc/init -a bothunter -u deploy;
      sudo start bothunter;
    }
  end
end