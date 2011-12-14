scheduler = Rufus::Scheduler.start_new  
  
scheduler.every("12h") do
   ParseGroups.perform
   ParseUsers.perform
end 