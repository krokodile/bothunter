class ParseUsers
  @queue = "bothunter"

  def self.perform
    token  = User.order('RANDOM()').first.token_for('vkontakte')
    persons = Person.where(state: 'pending')

    threads = []
    5.times do
      threads << Thread.new do
        while person = persons.pop
          Vk::ProfileParse.perform token, person
          puts "#{person.uid} has parsed"
        end
      end
    end

    threads.map &:join
  end
end
