class ParseUsers
  @queue = "bothunter"

  def self.perform
    token  = User.order('RANDOM()').first.token_for('vkontakte')
    persons = Person.where(state: 'pending')

    while person = persons.pop
      puts "#{person.uid} parsing..."
      Vk::ProfileParse.perform token, person
      puts "#{person.uid} has parsed"
    end
  end
end
