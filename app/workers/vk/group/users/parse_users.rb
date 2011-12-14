class ParseUsers
  @queue = "bothunter"
  def self.perform
    puts "Parsing users"
    ::Person.where(state: :pending).all.each do |person|
       Vk::ProfileParse.perform(person)
    end
  end
end
