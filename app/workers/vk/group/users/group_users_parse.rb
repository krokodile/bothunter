class Vk::GroupUsersParse
  @queue = "vk::long"

  def self.perform gid
    group = ::Vkontakte.find_group gid
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
        person_link = Vk::arg2uid (Nokogiri::HTML(person) / 'a:first').first['href']

        if person_link.present?
          if Vk.uid? person_link
            group.persons << Vk::Person.find_or_create_by_uid(person_link)
          else
            group.persons << Vk::Person.find_or_create_by_domain(person_link)
          end
        end
      end
    end
  end
end
