class ParseGroups
  @queue = "bothunter"

  def self.perform
    #puts "detecting groups"
    groups = ::Group.all.to_a
    threads_count = PARSE_GROUPS_THREADS
    threads = []
    groups.each do |group|
      if threads.size>=threads_count
        threads.each {|thr| thr.join }
        threads = []
      end
      threads << Thread.new do
        begin
         puts "detect group: #{group.title}"
         Vk::GroupUsersParse.perform(group.gid || group.domain  || group.link)
        rescue Exception=>e
          puts e
        end
      end

    end
  end
end