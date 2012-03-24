#!/usr/bin/env rake

require File.expand_path('../config/application', __FILE__)

I_KNOW_THAT_OPENSSL_VERIFY_PEER_EQUALS_VERIFY_NONE_IS_WRONG = nil

require 'resque/tasks'
#require 'resque_scheduler/tasks'

BotHunter::Application.load_tasks


task "resque:setup" => :environment do
  ENV['QUEUE'] = 'bot_filter'
end

#task "resque:scheduler_setup" => :environment

#desc "Start a parse workers"
#task 'bothunter:workers' => :environment do
#  Rake::Task["resque:setup"].reenable
#  Rake::Task["resque:setup"].invoke
#
#  Rake::Task["resque:work"].reenable
#  Rake::Task["resque:work"].invoke
#end

desc "Start a parse scheduler"

namespace :bothunter do
  desc "kill all workers (using -QUIT), god will take care of them"
  #task :stop_workers => :environment do
  #  pids = []
  #
  #  Resque.workers.each do |worker|
  #    pids << worker.to_s.split(/:/).second
  #  end
  #
  #  if pids.size > 0
  #    system("kill -QUIT #{pids.join(' ')}")
  #  end
  #end
  task :workers => :environment do
    parse_groups_thread = Thread.new do
      loop do
        ParseGroups.perform
        sleep 10
      end
    end

    parse_users_thread = Thread.new do
      loop do
        ParseUsers.perform
        sleep 10
      end
    end

    parse_groups_thread.join
    parse_users_thread.join
  end

  desc "Force restart"
  task :force_restart_through_upstart do
    system %Q{
      sudo stop bothunter;
      rm /etc/init/bothunter*;
      cd #{Rails.root};
      foreman export upstart /etc/init -a bothunter -u deploy;
      sudo start bothunter;
    }
  end
end
