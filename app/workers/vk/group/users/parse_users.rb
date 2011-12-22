class ParseUsers
  @queue = "bothunter"
  def self.perform
    puts "Parsing users"
    persons = ::Person.where(state: :pending).all
    persons.each do |person|
       Vk::ProfileParse.perform(person)
    end
  end
end
