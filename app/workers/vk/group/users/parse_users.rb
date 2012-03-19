class ParseUsers
  @queue = "bothunter"

  def self.perform
    token  = group.users.shuffle.first.token_for('vkontakte')
    persons = Person.where(state: :pending)

    persons.each do |person|
      Vk::ProfileParse.perform token, person
    end
  end
end
