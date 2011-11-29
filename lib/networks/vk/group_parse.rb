module Vk
  class GroupParse
    def self.parse group_url
      group_url = group_url.to_s
      domain = nil

      if group_url =~ /^[0-9]+$/
        gid = group_url
      elsif group_url =~ /^\/?club([0-9]+)$/
        gid = $1
      elsif group_url =~ /^.*\/club([0-9]+)$/
        gid = $1
      elsif group_url =~ /^.*\/([^\/]+)$/ or group_url =~ /^\/?([a-zA-Z\_0-9]+)$/
        _page = open("http://vkontakte.ru/#{$1}").read
        domain = $1
        gid = _page[/Groups\.init\(\{"group_id":\"?(\d+)\"?/, 1]
      else
        raise ArgumentError
      end

      _page = Nokogiri::HTML open("http://vkontakte.ru/club#{gid.to_i}").read
      title = (_page / 'div.top_header').first.content
    
      group = Vk::Group.find_or_create_by_gid gid: gid
      group.update_attributes!({
        title: title,
        domain: domain.presence || group.domain
      })

      admins_page = ::Vkontakte.http_post(
        'al_groups.php',
        {
          act: 'show_leaders',
          al: 1,
          oid: "-#{gid}",
        }
      ).to_nokogiri_html

      admins_link = (admins_page / 'div.info_wide a')
      admins_link.each do |admin|
        person = ::Vk.arg2uid(admin['href'])

        if person.present?
          if Vk.uid? person
            group.admins << Vk::Person.find_or_create_by_uid(person)
          else
            group.admins << Vk::Person.find_or_create_by_domain(person)
          end
        end
      end if admins_link

      if block_given?
        yield group
      end

      gid
    end
  end
end
