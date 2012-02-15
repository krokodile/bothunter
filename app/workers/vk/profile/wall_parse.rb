#coding = utf-8
class WallParse
  @queue = "bothunter"
  def self.perform person
    api = ::Vk::API.new()
    posts = api.wall_get(:owner_id => person.uid)[1..-1]
    posts.each do |post|
      id = post["id"]
      content = post["text"]
      repost_from = post["copy_post_id"]
      pub_date = DateTime.parse(Time.at(post["date"]).to_s)
      comments_count = post["comments"]["count"]
      likes_count = post["likes"]["count"]
      own_post = post["from_id"] == post["to_id"]
      src = nil
      if post["media"].present?
        src = post["media"]["src"]
      end
      wallpost = WallPost.new(uid: id, pub_date: pub_date, content: content,
                     src: src, comments_count: comments_count,
                     likes_count: likes_count, repost_from: repost_from, own_post: own_post)
      person.wall_posts << wallpost
      #post.person = person
      wallpost.save!
      person.save!
    end
    return person
  end
end