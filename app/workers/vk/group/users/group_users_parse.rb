class Vk::GroupUsersParse
  @queue = "bothunter"


  def self.perform gid
    group = ::Vkontakte.find_group gid
    #puts "detecting users of #{group.gid} #{group.title}"
    gid = group.gid
    api = ::Vk::API.new()
    offset = 0
    count = 0
    do_next = true
    while (offset<=count) do
      Rails.logger.debug ("count: #{count} offset: #{offset}")
      results = api.groups_getMembers(:gid=> gid, :offset => offset)
      count = results['count']
      persons = results['users']
      offset +=1000
      persons.each do |person_link|
        Rails.logger.debug  ("detecting person: #{person_link}")
          person = ::Vkontakte.find_person(person_link)
          if !group.persons.include?(person)
            group.persons << person
          end
          person.save!
          group.save!
        Rails.logger.debug  ("detected person: #{person_link}")
          #::ProfileParse.perform person

          #else
          #group.people << Vk::Person.find_or_create_by(domain:person_link)
          #end
        end

      end
    end
end
