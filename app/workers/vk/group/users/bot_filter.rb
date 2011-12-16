class BotFilter
  def self.delete_robots (gid, login, password)
    #gid - group id, string
    cookies = VkontakteHeaders.user_sign_in(login, password)
    group = ::Vkontakte.find_group gid
    puts cookies
    puts "detecting users of #{group.title}"
    #gid = group.gid
    ::Vkontakte.parse_each_item({
      method: 'post',
      gjson: false,
      offset: 25,
      url: 'al_groups.php',
      cookies: cookies,
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
      puts "Size is: #{persons.size}"
      persons.each do |person_source|
        #puts "Iterate!"
        #puts person_source
        person_html = person_source.to_nokogiri_html
        #puts person_html
        #person = ::Vkontakte.find_person(person_link)
        #if !group.persons.include?(person)
        js = (person_html / '.group_p_actions a').first[:onclick]
        js_match = /GroupsEdit.memberAction\(this, 'delete', (\d*), (\d*), '(.*)', -1\)/.match(js)
        uid = js_match[2]
        hash = js_match[3]
        #puts "UID: #{uid} HASH: #{hash}"
        if Person.where(uid: uid, state: :robot).count>0
          puts "DELETE #{uid}"
          req_params = {
              cookies: cookies,
              act: 'member_action',
              action: 'delete',
              al: '1',
              gid: gid,
              hash: hash,
              mid: uid
          }
          begin
            #TODO make normal code, please
            Vkontakte.http_post("/al_groups.php",req_params)
            Kernel.sleep(1)
          rescue => e
            puts "Raised error on #{uid}, analitycs nead"
          end
          Person.where(uid: uid, state: :robot).delete
        end
        #  end
          #group.save
          #::ProfileParse.perform person

          #else
          #group.people << Vk::Person.find_or_create_by(domain:person_link)
          #end
        #end
      end
    end
  end
end