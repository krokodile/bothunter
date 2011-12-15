Dir.glob(File.expand_path('./app/workers/**/*.rb', Rails.root)).each do |worker|
  require worker
end

scheduler = Rufus::Scheduler.start_new
  
scheduler.every("12h") do
   ::Group.all.each do |group|
      puts "detect group: #{group.title}"
      Vk::GroupUsersParse.perform(group.gid || group.domain  || group.link)
    end

   ::Person.where(state: :pending).all.each do |person|
       Vk::ProfileParse.perform(person)
    end
end 