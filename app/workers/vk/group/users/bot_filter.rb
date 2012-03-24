class BotFilter
  @queue = :bot_filter

  def self.perform(gid)
    group = ::Vkontakte.find_group gid
    superuser = AccountStore.credentials[:vkontakte][:superuser]
    cookies = VkontakteHeaders.user_sign_in(superuser[:username], superuser[:password])
    #puts "Size is: #{persons.size}"
    self.each_members(gid,cookies).each do |person_html|
      #person_html = person_source.to_nokogiri_html
      js = (person_html / '.group_p_actions a').first[:onclick]
      js_match = /GroupsEdit.memberAction\(this, 'delete', (\d*), (\d*), '(.*)', -1\)/.match(js)
      uid = js_match[2]
      hash = js_match[3]
      person = Person.where(uid: uid).first
      if person.uid == superuser[:ident] || person.domain == superuser[:ident]
        puts "is our superuser!"
        next
      end
      if person.state == 'robot'
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
        group.people.where(uid: uid).delete
      end
    end
  end

  def self.each_members gid,cookies
    offset = 0
    has_next = true
    ret_items = []
    while (has_next) do
      puts "offset is #{offset} of #{gid}"
      data = Vkontakte.http_post("al_groups.php", {
           act: 'people_get',
           al: 1,
           tab: 'members',
           gid: gid,
           offset: offset,
           cookies: cookies})
      #puts data
      data_html = data.to_nokogiri_html
      items = (data_html / ".group_p_row")
      items.each do |item|
        puts item
        ret_items << item
      end
      Kernel.sleep 1
      offset+=25
      if items.size<25
        break
      end
    end
    ret_items
  end
end
