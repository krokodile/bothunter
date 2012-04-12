#!/usr/bin/env rake

require File.expand_path('../config/application', __FILE__)

I_KNOW_THAT_OPENSSL_VERIFY_PEER_EQUALS_VERIFY_NONE_IS_WRONG = nil

require 'resque/tasks'

BotHunter::Application.load_tasks

task "resque:setup" => :environment do
  ENV['QUEUE'] = 'bot_filter'
end

desc "Start a parse scheduler"
namespace :bothunter do
  desc "Start bothunter workers"
  task workers: :environment do
    Thread.new do
      loop do
        begin
          ParseGroups.perform
        rescue Exception => e
          puts e.backtrace
        end

        sleep 60
      end
    end.join

    Thread.new do
      loop do
        begin
          ParseUsers.perform
        rescue Exception => e
          puts e.backtrace
        end

        sleep 60
      end
    end.join
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
