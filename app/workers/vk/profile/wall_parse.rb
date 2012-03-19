# encoding: utf-8

class WallParse
  @queue = "bothunter"

  def self.perform token, person
    posts = ::Vk::API.call_method token, 'wall.get', owner_id: person.uid #TODO: without offset?

    return person unless posts.is_a? Array

    posts.select! { |post| post.is_a? Hash }

    posts.each do |post|
      id             = post["id"]
      text           = post["text"]
      copy_post_id   = post["copy_post_id"]
      pub_date       = DateTime.parse(Time.at(post["date"]).to_s)
      comments_count = post["comments"]["count"]
      likes_count    = post["likes"]["count"]
      own_post       = post["from_id"] == post["to_id"]
      src = nil

      if post["media"].present?
        src = post["media"]["src"]
      end

      wall_post = person.wall_posts.create(
        post_id: id,
        pub_date: pub_date,
        text: text,
        src: src,
        comments_count: comments_count.to_i,
        likes_count: likes_count.to_i,
        copy_post_id: copy_post_id,
        own_post: own_post
      )

      wall_post.save!
    end

    person
  end
end