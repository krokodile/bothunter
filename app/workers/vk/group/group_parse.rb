module Vk
  class GroupParse
    def self.parse group_url
      #puts "parsing #{group_url}"
      #agent = Mechanize.new
      #group_url = group_url.to_s
      #domain = nil
      #if group_url =~ /^[0-9]+$/
      #  gid = group_url
      #elsif group_url =~ /^\/?club([0-9]+)$/
      #  gid = $1
      #elsif group_url =~ /^.*\/club([0-9]+)$/
      #  gid = $1
      #elsif group_url =~ /^.*\/([^\/]+)$/ or group_url =~ /^\/?([a-zA-Z\_0-9]+)$/
      #  _page = agent.get("http://vk.com/#{$1}").body
      #  domain = $1
      #  gid = _page[/Groups\.init\(\{"group_id":\"?(\d+)\"?/, 1]
      #else
      #  raise ArgumentError
      #end
      #puts "group id is #{gid}"
      ##_page = agent.get("http://vk.com/club#{gid.to_i}")
      #title = (_page.search 'div.top_header').first.content
      if group_url =~ /.*\/?.*([0-9]+)$/
        gid = $1
      elsif group_url =~ /.*\/(.*)/
        gid = $1
      else
        gid = group_url
      end
      api = ::Vk::API.new()
      puts gid
      group_info = api.groups_getById(:gid=> gid)[0]
      group = ::Group.find_or_create_by(gid: group_info["gid"])
      group.update_attributes!({
        title: group_info["name"],
        domain: group_info["screen_name"]
      })
      return group
    end
  end
end
