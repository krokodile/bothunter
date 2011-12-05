class ParseAll
  @queue = "vk::long"

  def self.perform
    ::Group.all.each do |group|
      Vk::GroupUsersParse.perform group.gid || group.domain  || group.link
    end
    ::Person.where(state: :pending).all.each do |person|
      Vk::ProfileParse.perform person.uid
    end
  end
end