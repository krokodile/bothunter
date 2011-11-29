class ProfileParse
  def self.perform uid
    ::Vkontakte.parse_each_item({
      method: 'post',
      offset: 10,
      url: 'al_wall.php',
      #last_date: group.posts.by_date.first.try(:pub_date).try(:to_datetime),
      thread_count: THREAD_COUNT,
      params: {
        act: 'get_wall',
        al: 1,
        type: 'all', # own - for group
        owner_id: "#{uid}", # without minus for person wall
      },
      item_for_parse: 'div.post',
    }) do |items|
      items.each do |item|
        item_html = item.to_nokogiri_html
        uid = /wpt(\d*_\d*)/.match((item_html /  'div[id^=wpt]').first['id'])[1]
        pub_date = russian_date_scan((item_html / '.rel_date').first.content)
        puts pub_date
        conent = nil
        if content_html = (item_html / 'div.wall_post_text').presence
          content = content_html.first.content.strip.gsub(/.*показать полностью\.\./, '')
        end
        src = nil
        if content_html = (item_html / 'div.post_media img').presence
          src = content_html.first['src']
        elsif content_html = (item_html / 'div.post_media div.audio').presence
          src = content_html.first.content
        elsif content_html = (item_html / 'div.post_media div.video').presence
          src = content_html.first['href']
        end
        puts content
        puts src

        if count_node = (item_html / '.wrh_text').first.presence
          comments_count = /.* (\d+) .*/.match(count_node.content)[1].to_i
        end
        comments_count ||= (item_html / '.reply').size
        likes_count = (item_html / 'span.like_count').first.content.to_i rescue nil
        likes_count ||= 0

        puts comments_count
        puts likes_count

      end
    end
  end
end