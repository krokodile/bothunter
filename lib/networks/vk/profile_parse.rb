# encoding: utf-8
VK_NOPHOTO = "http://vk.com/images/question_c.gif"

class Vk::ProfileParse
  def self.parse uid
    puts uid
    person = Person.find_or_create_by(uid:uid)
    puts "parsing person #{person}"
    api = ::Vk::API.new
    profile = api.getProfiles({
          uids: person.uid || person.domain,
          fields: 'uid, domain, first_name, last_name, photo'
    })
    page = nil
    begin
      page = ::Vkontakte.http_get("/id#{uid}").to_nokogiri_html
    rescue Exception => e
      person.state = :robot
      person.save
      return
    end
    if (page / '.profile_deleted').present?
      person.state = :robot
      person.save
      return
    end
    person.write_attributes(profile[0])
   # person.save
    WallParse.perform(person.uid)
    FriendsParse.perform(person.uid)
    person.save
  end

  def self.perform uid
    if !uid.present?
      return
    end
    self.parse uid
    person = Person.where(uid:uid).first
    if !person.presence
      return
    end
    #person = Person.where(uid:uid).first
    if person.state!= :pending
      return
    end
    bot_balls = 0
    if person.wall_posts.count==0
      bot_balls += 10
    if person.photo == VK_NOPHOTO
      bot_balls+=10
    end
    elsif person.wall_posts.where(:repost_from.exists=>true).count/person.wall_posts.count.to_f>0.95
      bot_balls += 4
    end
    if person.wall_posts.where(own_post:false).count==0
      bot_balls += 4
    end
    if person.friends_count == 0
      bot_balls +=4

    elsif person.friends_count <= 25
      bot_balls +=3
    end
    if  person.wall_posts.where(:likes_count.in =>[1,2,3]).count/person.wall_posts.where(:likes_count.nin => [1,2,3]).count.to_f<=0.95
      bot_balls +=3
    end
    if person.wall_posts.where(:comments_count.gte => 1).count == 0
      bot_balls +=3
    end
    puts bot_balls
    if bot_balls <= 8
      person.state = :human
    elsif bot_balls <= 16
      person.state = :undetected
    else
      person.state= :robot
    end
    person.save
  end
  #Person.by_state(:pending).each do |person|

  #end

end