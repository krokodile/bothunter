# encoding: utf-8
VK_NOPHOTO = "http://vk.com/images/question_c.gif"

class Vk::ProfileParse
  @queue = "bothunter"
  def self.parse person
    #puts "token is: #{::AccountStore.next(:vkontakte, :accounts)['token']}"
    api = ::Vk::API.new()
    profile = api.getProfiles({
          uids: person.uid || person.domain,
          fields: 'uid, domain, first_name, last_name, photo, bdate'
    })
    #puts profile[0]
    #person.write_attributes(profile[0])
    person.uid = person.uid || profile[0]["uid"]
    person.domain = person.uid || profile[0]["domain"]
    person.first_name = profile[0]["first_name"]
    person.last_name = profile[0]["last_name"]
    person.photo = profile[0]["photo"]
    bdate = nil
    begin
      bdate = DateTime.parse profile[0]["bdate"]
    rescue
      bdate = nil
    end
    person.bdate = bdate
    person.save!
    #puts "scrapping person #{person.uid} #{person.domain}"
    web_client = Mechanize.new
    socks = AccountStore.next_socks
    web_client.agent.set_socks(socks[:host],socks[:port])
    if person.uid.present?
      page = web_client.get("http://vk.com/id#{person.uid}",{},false)
    elsif
      page = web_client.get("http://vk.com/#{person.domain}",{},false)
    else
      puts "No domain, no ID.... something wrong"
    end
    #puts page.to_s
    banned = false
    if  (page.search '.profile_blocked').present?
      puts "person #{person.uid || person.domain} blocked"
      banned = true
    if (page.search "img[src='/images/deactivated_tir.png']").present?
      banned = true
    end
    #elsif (page.search '.profile_deleted').present?
    #  puts "person #{person.uid || person.domain} banned"
    #  banned = true
    end
    if banned
      person.state = :robot
      r =  /^(.*) (.*)$/.match((page.search "#title").first.content)
      person.first_name = r[1]
      person.last_name = r[2]
      person.save!
      return person
    end
    #person.save
    person = WallParse.perform(person)
    person.friends_count = api.friends_get({:uid => person.uid}).size
    person.save!
    #puts "Person is #{person}"
    return person
  end

  def self.perform (person)
    Rails.logger.debug("start to detect person #{person.uid || person.domain}")
    #puts "detecting person: #{person.uid || person.domain || "wrong"}"
    person = self.parse person
    #puts "Person is #{person.uid} #{person.domain}"
    if !person.present?
      puts "person is null. something wrong"
      return
    end
    if !person.uid.present?
        puts "person uid unpresent"
      return
    end
    #person = Person.where(uid:uid).first
    if person.state!= :pending
      #puts "person: #{person.uid} already detected"
      return
    end
    Rails.logger.debug("person #{person.uid || person.domain} parsed. detecting")
    bot_points = 0
    if person.wall_posts.count==0
      bot_points += 10
    if person.photo == "http://vk.com/images/camera_a.gif"
      bot_points+=10
    end
    elsif person.wall_posts.where(:repost_from.exists=>true).count/person.wall_posts.count.to_f>0.95
      bot_points += 4
    end
    if person.wall_posts.where(own_post:false).count==0
      bot_points += 4
    end
    if person.friends_count == 0
      bot_points +=10

    elsif person.friends_count <= 25
      bot_points +=3
    end
    if  person.wall_posts.where(:likes_count.in =>[1,2,3]).count/person.wall_posts.where(:likes_count.nin => [1,2,3]).count.to_f<=0.95
      bot_points +=3
    end
    if person.wall_posts.where(:comments_count.gte => 1).count == 0
      bot_points +=3
    end
    #puts "bot_points is #{bot_points}"
    if bot_points <= 14
      person.state = :human
      #person.save!
    elsif bot_points <= 17
      person.state = :undetected
      #person.save!
    else
      person.state= :robot
      #person.save!
    end
    person.save!
    Rails.logger.info("user #{person.uid} is #{person.state} with #{bot_points} points")
    return person
  end

end