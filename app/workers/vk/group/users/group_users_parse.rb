class Vk::GroupUsersParse
  @queue = "bothunter"

  def self.perform gid
    group = ::Vkontakte.find_group gid
    puts "detecting users of #{group.gid} #{group.title}"
    gid = group.gid
    ::Vkontakte.parse_each_item({
      method: 'post',
      offset: 96,
      url: 'al_page.php',
      thread_count: THREAD_COUNT,
      params: {
        act: 'show_members_box',
        al: 1,
        tab: 'members',
        gid: gid,
      },
      item_for_parse: 'div.wide_box_user',
    }) do |persons|
      #TODO: Remove sign out users

      persons.each do |person|
        #puts "detecting person: #{person}"
        person_link = Vk::arg2uid (Nokogiri::HTML(person) / 'a:first').first['href']
        if person_link.present?
          puts person_link
          #if Vk.uid? person_link
          person = ::Vkontakte.find_person(person_link)
          if person.state != :pending
            break
          end
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
