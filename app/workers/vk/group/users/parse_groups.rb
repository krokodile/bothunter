class ParseGroups
  @queue = "bothunter"

  def self.perform
    puts "detecting groups"
    ::Group.all.each do |group|
      puts "detect group: #{group.title}"
      Vk::GroupUsersParse.perform(group.gid || group.domain  || group.link)
    end
  end
end