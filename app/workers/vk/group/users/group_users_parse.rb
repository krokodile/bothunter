class Vk::GroupUsersParse
  @queue = "bothunter"

  def self.perform gid
    group = ::Vkontakte.find_group gid
    puts "detecting users of #{group.gid} #{group.title}"
    gid = group.gid
   ::Vkontakte.parse_each_item({
      method: 'post',
      offset: 25,
      url: 'al_groups.php',
      thread_count: THREAD_COUNT,
      params: {
        act: 'people_get',
        al: 1,
        tab: 'members',
        gid: gid
      },
      item_for_parse: '.group_p_row',
    }) do |persons|
      #TODO: Remove sign out users

      persons.each do |person|
        #puts "detecting person: #{person}"
        person_link = Vk::arg2uid (Nokogiri::HTML(person) / 'a:first').first['href']
        if person_link.present?
          puts person_link
          #if Vk.uid? person_link
          person = ::Vkontakte.find_person(person_link)
          if !group.persons.include?(person)
            group.persons << person
          end
          person.save!
          group.save!
          #::ProfileParse.perform person

          #else
          #group.people << Vk::Person.find_or_create_by(domain:person_link)
          #end
        end

      end
    end
  end
end
