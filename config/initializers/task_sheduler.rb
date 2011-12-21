Dir.glob(File.expand_path('./app/workers/**/*.rb', Rails.root)).each do |worker|
  require worker
end

#scheduler = Rufus::Scheduler.start_new
if !Rails.env.development?

  Thread.new do
    loop do
    ::Group.all.each do |group|
        puts "detect group: #{group.title}"
        Vk::GroupUsersParse.perform(group.gid || group.domain  || group.link)
      end
    end
  end

  Thread.new do
    loop do
      ::Person.where(state: :pending).all.each do |person|
         Vk::ProfileParse.perform(person)
      end
    end
  end
end