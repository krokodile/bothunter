# encoding: utf-8

class Vk::ProfileParse
  @queue = "bothunter"

  def self.parse token, person
    profile = Vk::API.call_method token, 'getProfiles', {
      uids: person.uid || person.domain,
      fields: 'uid,domain,first_name,last_name,photo,bdate'
    }

    person.uid      ||= profile["uid"]
    person.domain   ||= profile["domain"]
    person.first_name = profile["first_name"]
    person.last_name  = profile["last_name"]
    person.photo      = profile["photo"]
    person.bdate      = Chronic.parse(profile["bdate"])

    person.save!

    web_client = Mechanize.new
    #socks = AccountStore.next_socks
    #web_client.agent.set_socks(socks[:host], socks[:port])

    if person.uid.present?
      page = web_client.get("http://vk.com/id#{person.uid}", {}, false)
    elsif person.domain.present?
      page = web_client.get("http://vk.com/#{person.domain}", {}, false)
    else
      return
    end

    banned = false
    if (page.search '.profile_blocked').present?
      puts "person #{person.uid || person.domain} blocked"
      banned = true
    elsif (page.search "img[src='/images/deactivated_tir.png']").present?
      banned = true
    end
    #elsif (page.search '.profile_deleted').present?
    #  puts "person #{person.uid || person.domain} banned"
    #  banned = true

    if banned
      person.state = 'bot'
      r = /^(.*) (.*)$/.match((page.search "#title").first.content)
      person.first_name = r[1]
      person.last_name = r[2]
      person.save!

      return person
    end

    person = WallParse.perform token, person
    person.friends_count = ::Vk::API.call_method(token, 'friends.get', uid: person.uid).size rescue 0
    person.save!

    person
  end

  def self.perform token, person
    person = self.parse token, person

    return unless person.present? || person.uid.present? || person.state == 'pending'

    bot_points = 0

    if person.wall_posts.count == 0
      bot_points += 10

      if person.photo == "http://vk.com/images/camera_a.gif"
        bot_points += 10
      end
    elsif (person.wall_posts.where(['copy_post_id IS NOT NULL']).count /
          person.wall_posts.count.to_f) > 0.95
      bot_points += 4
    end

    if person.wall_posts.where(own_post: false).count == 0
      bot_points += 4
    end
    if person.friends_count == 0
      bot_points += 10
    elsif person.friends_count <= 25
      bot_points += 3
    end

    if person.wall_posts.where(['likes_count IN (?)', [1,2,3]]).count /
        person.wall_posts.where(['likes_count NOT IN (?)', [1,2,3]]).count.to_f <= 0.95

      bot_points += 3
    end

    if person.wall_posts.where(['comments_count >= ?', 1]).count == 0
      bot_points += 3
    end

    if bot_points <= 14
      person.state = 'alive'
    elsif bot_points <= 17
      person.state = 'unknown'
    else
      person.state= 'bot'
    end

    person.save!

    person
  end
end
