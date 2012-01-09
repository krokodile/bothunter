#coding = utf-8
class WallParse
  @queue = "bothunter"
  def self.old? item
    #puts "is to old?"
    if date_html = (item / '.rel_date').presence
      pub_date = russian_date_scan((date_html.first.content))
      if !pub_date.present?
        return false
      end
      #puts "pubdate is: #{pub_date}"
      if pub_date<1.months.ago
        return true
      end
    end
    return false
  end

  def self.do_parse (item,person)
    item_html = item.to_nokogiri_html(true)
    post_uid = /wpt(\d*_\d*)/.match((item_html /  'div[id^=wpt]').first['id'])[1]
    if date_html = (item_html / '.rel_date').presence
     pub_date = russian_date_scan((date_html.first.content))
    end
    #pub_date ||= 1.months.ago-1.days
    #puts pub_date
    content = nil
    src = nil
    if content_html = (item_html / 'div.post_media div.audio').presence
     return {parse_next: pub_date.nil? || pub_date >= 1.months.ago, person: person}
    end
    if content_html = (item_html / 'div.wall_post_text').presence
     content = content_html.first.content.strip.gsub(/.*показать полностью\.\./, '')
    end

    #if content_html = (item_html / 'div.post_media div.audio').presence

    if content_html = (item_html / 'div.post_media img').presence
     src = content_html.first['src']
    elsif content_html = (item_html / 'div.post_media div.video').presence
     src = content_html.first['href']
    #else next
    end
    #puts content
    #puts src

    if count_node = (item_html / '.wrh_text').presence
     comments_count = /.* (\d+) .*/.match(count_node.first.content)[1].to_i
    end
    comments_count ||= (item_html / '.reply').size
    likes_count = (item_html / 'span.like_count').first.content.to_i rescue nil
    likes_count ||= 0
    repost_from = nil
    if repost_from_el = (item_html / '.published_by_wrap .published_by').first.presence
     repost_from = repost_from_el[:href]
    end
    #puts comments_count
    #puts likes_count
    #puts "repost: #{repost_from}"
    #puts pub_date
    #puts pub_date > 1.months.ago
    own_post = true
    author_attr = Vk::arg2uid((item_html / 'a.author').first["href"])
    if author_attr!=person.uid && author_attr != person.domain
      own_post = false
    end
    #puts "isOwn: #{own_post}"
    #if (pub_date) > 1.months.ago
    post = WallPost.new(uid: post_uid, pub_date: pub_date, content: content,
                     src: src, comments_count: comments_count,
                     likes_count: likes_count, repost_from: repost_from, own_post: own_post)
    person.wall_posts << post
     #post.person = person
    post.save!
    person.save!
    return {parse_next: pub_date.nil? || pub_date >= 1.months.ago, person: person}
  end

  def self.perform person
    #person = Person.where(uid:uid).first
    if !person.present?
     return
    end
    parse_next = true
    offset = 0
    options = {
    #params: {
       act: 'get_wall',
       al: 1,
       type: 'all', # own - for group
       owner_id: "#{person.uid}", # without minus for person wall
    # }
    #noauth: true
    }
     while parse_next do
      data = Vkontakte.http_post('al_wall.php',options.merge({offset: offset}),false)
      #puts data
      _items = (data.to_nokogiri_html / "div.post").map { |item|
        item.inner_html.force_encoding('utf-8')
      }
      if _items.empty? or _items.nil?
        if data.to_s =~ /Вы попытались загрузить более одной однотипной страницы в секунду/u
          Thread.sleep 3
          next
        else
          break
        end
      end
      _items.each do |item|
        res = self.do_parse(item,person)
        person = res[:person]
        parse_next =  res[:parse_next]
      end
      offset += 10
    end
    return person
  end
end