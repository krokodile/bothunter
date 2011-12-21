# encoding: utf-8
VK_NOPHOTO = "http://vk.com/images/question_c.gif"

class Vk::ProfileParse
  @queue = "bothunter"
  def self.parse person
    puts "parsing person #{person}"
    api = ::Vk::API.new
    profile = api.getProfiles({
          uids: person.uid || person.domain,
          fields: 'uid, domain, first_name, last_name, photo'
    })
    puts profile[0]
    person.write_attributes(profile[0])
    if person.uid.present?
      page = ::Vkontakte.http_get("/id#{person.uid}").to_nokogiri_html
    elsif
      page = ::Vkontakte.http_get("/#{person.domain}").to_nokogiri_html
    else
      puts "No domain, no ID.... something wrong"
    end
    if (page / '.profile_deleted').present?
      person.state = :robot
      r =  /^(.*) (.*)$/.match((page / "#title").first.content)
      person.first_name = r[1]
      person.last_name = r[2]
      person.save
      return Person.where(uid: person.uid).first
    end
    person.save
    WallParse.perform(person.uid)
    FriendsParse.perform(person.uid)
    return Person.where(uid: person.uid).first
  end

  def self.perform person
    puts "detecting person: #{person.uid || person.domain || "wrong"}"
    person = self.parse person
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
      puts "person: #{person.uid} already detected"
      return
    end
    bot_points = 0
    if person.wall_posts.count==0
      bot_points += 10
    if person.photo == VK_NOPHOTO
      bot_points+=10
    end
    elsif person.wall_posts.where(:repost_from.exists=>true).count/person.wall_posts.count.to_f>0.95
      bot_points += 4
    end
    if person.wall_posts.where(own_post:false).count==0
      bot_points += 4
    end
    if person.friends_count == 0
      bot_points +=4

    elsif person.friends_count <= 25
      bot_points +=3
    end
    if  person.wall_posts.where(:likes_count.in =>[1,2,3]).count/person.wall_posts.where(:likes_count.nin => [1,2,3]).count.to_f<=0.95
      bot_points +=3
    end
    if person.wall_posts.where(:comments_count.gte => 1).count == 0
      bot_points +=3
    end
    puts "bot_points is #{bot_points}"
    if bot_points <= 8
      person.state = :human
    elsif bot_points <= 16
      person.state = :undetected
    else
      person.state= :robot
    end
    puts "user #{person.uid} is #{person.state} "
    person.save
  end

end