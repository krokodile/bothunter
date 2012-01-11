module Vk::AllProfilesParse
  def self.perform
    persons = []
    api = ::Vk::API.new(::AccountStore.next(:vkontakte, :accounts)['token'])

    Person.limit(10).all.to_a.each do  |person|
      puts person.uid || person.domain
      begin
        profile = api.getProfiles({
          uids: person.uid || person.domain,
          fields: 'uid, first_name, last_name, nickname, screen_name, sex, bdate, city, country, timezone, photo, photo_medium, photo_big, has_mobile, rate, contacts, education, online, counters'
        })
        persons << profile[0]
      rescue
        puts "user #{person.uid || person.domain} fails"
      end
    end
    File.open('profiles.json', 'w') {|f| f.puts persons.to_json }
  end
end