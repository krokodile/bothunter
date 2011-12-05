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
        _page = ::Vkontakte.http_get("http://vkontakte.ru/#{$1}")
        domain = $1
        gid = _page[/Groups\.init\(\{"group_id":\"?(\d+)\"?/, 1]
      else
        raise ArgumentError
      end

      _page = ::Vkontakte.http_get("club#{gid.to_i}").to_nokogiri_html
      title = (_page / 'div.top_header').first.content
    
      group = ::Group.find_or_create_by(gid: gid)
      group.update_attributes!({
        title: title,
        domain: domain.presence || group.domain
      })
      return group
    end
  end
end
