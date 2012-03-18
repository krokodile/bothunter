class ParseGroups
  @queue = "bothunter"

  def self.perform
    groups = ::Group.all.to_a

    groups.each do |group|
      ::Vk::GroupUsersParse.perform group.gid
    end
  end
end