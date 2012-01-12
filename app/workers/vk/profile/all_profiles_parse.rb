module Vk::AllProfilesParse
  def self.perform
    api = ::Vk::API.new(::AccountStore.next(:vkontakte, :accounts)['token'])
    count = Person.count
    offset = 0
    while offset<count do
      persons = []
      Person.limit(500).skip(offset).all.to_a.each do  |person|
        puts person.uid || person.domain
        begin
          profile = api.getProfiles({
            uids: person.uid || person.domain,
            fields: 'uid, first_name, last_name, nickname, screen_name, sex, bdate, city, country, timezone, photo, photo_medium, photo_big, has_mobile, rate, contacts, education, online, counters'
          })
          persons << profile[0]
        rescue Timeout::Error
          puts "timeout"
        rescue
          puts "user #{person.uid || person.domain} fails"
        end
      end
      File.open("profiles_#{offset}.json", 'w') {|f| f.puts persons.to_json }
      offset+=500
    end
  end
end