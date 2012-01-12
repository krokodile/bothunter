module Vk::AllProfilesParse
  def self.perform
    persons = []
    count = Person.count
    offset = 0
    while offset<count do
      api = ::Vk::API.new(::AccountStore.next(:vkontakte, :accounts)['token'])

      Person.limit(500).skip(offset).all.to_a.each do  |person|
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
        offset+=500
      end
      File.open("profiles.json_#{offset}", 'w') {|f| f.puts persons.to_json }
    end
  end
end