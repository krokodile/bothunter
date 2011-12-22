#coding = utf-8
class WallParse
  @queue = "bothunter"
  def self.old? item
    puts "is to old?"
    if date_html = (item / '.rel_date').presence
      pub_date = russian_date_scan((date_html.first.content))
      if !pub_date.present?
        return false
      end
      puts "pubdate is: #{pub_date}"
      if pub_date<1.months.ago
        return true
      end
    end
    return false
  end
  def self.perform person
     #person = Person.where(uid:uid).first
     if !person.present?
       return
     end
     ::Vkontakte.parse_each_item({
       method: 'post',
       offset: 10,
       url: 'al_wall.php',
       date_detector: -> item { WallParse.old?(item)},
       #last_date: group.posts.by_date.first.try(:pub_date).try(:to_datetime),
       thread_count: THREAD_COUNT,
       params: {
         act: 'get_wall',
         al: 1,
         type: 'all', # own - for group
         owner_id: "#{person.uid}", # without minus for person wall
       },
       item_for_parse: 'div.post',
     }) do |items|
       items.each do |item|
         item_html = item.to_nokogiri_html(true)
         begin
          post_uid = /wpt(\d*_\d*)/.match((item_html /  'div[id^=wpt]').first['id'])[1]
         rescue => e
           break
         end
         if date_html = (item_html / '.rel_date').presence
           pub_date = russian_date_scan((date_html.first.content))
         end
         #pub_date ||= 1.months.ago-1.days
         #puts pub_date
         content = nil
         src = nil
         if content_html = (item_html / 'div.post_media div.audio').presence
           next
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
         #end



         #next unless pub_date
       end
     end
    return person
   end  
end